#!/usr/bin/env zsh
# Network and API Functions
# Functions for working with APIs and network requests

# Lazy load guard (unique to this file)
[[ -n "${_API_FUNCTIONS_LOADED}" ]] && return
_API_FUNCTIONS_LOADED=1

# Curl wrapper that automatically pipes JSON/NDJSON output to jqp
# Note: This overrides the default curl command - consider if you want this behavior
curl_with_jqp() {
    # Check if jqp is available
    if ! command -v jqp >/dev/null 2>&1; then
        # If jqp is not available, just run regular curl
        command curl "$@"
        return $?
    fi

    # Create temporary files for output and headers
    local temp_output=$(mktemp /tmp/curl_output.XXXXXX)
    local temp_headers=$(mktemp /tmp/curl_headers.XXXXXX)
    
    # Run curl and capture output and headers
    local curl_exit_code
    command curl -D "$temp_headers" -o "$temp_output" "$@"
    curl_exit_code=$?
    
    # If curl failed, show the output and return
    if [[ $curl_exit_code -ne 0 ]]; then
        cat "$temp_output"
        rm -f "$temp_output" "$temp_headers"
        return $curl_exit_code
    fi
    
    # If output is empty, just show headers if any
    if [[ ! -s "$temp_output" ]]; then
        cat "$temp_headers"
        rm -f "$temp_output" "$temp_headers"
        return $curl_exit_code
    fi
    
    # Check Content-Type header for JSON
    local content_type=$(grep -i "^content-type:" "$temp_headers" | tail -1 | cut -d: -f2- | tr -d ' \r\n' | tr '[:upper:]' '[:lower:]')
    local is_json_content_type=false
    
    if [[ "$content_type" == *"application/json"* ]] || [[ "$content_type" == *"application/ndjson"* ]] || [[ "$content_type" == *"text/json"* ]]; then
        is_json_content_type=true
    fi
    
    # Try to detect JSON by content (check first few characters)
    local first_chars=$(head -c 10 "$temp_output" | tr -d '[:space:]')
    local looks_like_json=false
    
    # Check if it starts with JSON-like characters or is NDJSON
    if [[ "$first_chars" =~ ^[\{\[] ]] || [[ -n "$(head -1 "$temp_output" | jq . 2>/dev/null)" ]]; then
        looks_like_json=true
    fi
    
    # Check if the entire content is valid JSON
    local is_valid_json=false
    if jq . "$temp_output" >/dev/null 2>&1; then
        is_valid_json=true
    fi
    
    # Check if it's NDJSON (newline-delimited JSON)
    local is_ndjson=false
    if [[ "$is_valid_json" == false ]] && [[ "$looks_like_json" == true ]]; then
        # Try to validate as NDJSON (each line should be valid JSON)
        local ndjson_valid=true
        while IFS= read -r line; do
            if [[ -n "$line" ]] && ! echo "$line" | jq . >/dev/null 2>&1; then
                ndjson_valid=false
                break
            fi
        done < "$temp_output"
        if [[ "$ndjson_valid" == true ]]; then
            is_ndjson=true
        fi
    fi
    
    # Show headers if requested (when -I, -head, or -D options are used)
    local show_headers=false
    for arg in "$@"; do
        if [[ "$arg" == "-I" ]] || [[ "$arg" == "--head" ]] || [[ "$arg" == "-D" ]] || [[ "$arg" == "--dump-header" ]]; then
            show_headers=true
            break
        fi
    done
    
    if [[ "$show_headers" == true ]]; then
        cat "$temp_headers"
    fi
    
    # If it's JSON or NDJSON, pipe to jqp; otherwise show normally
    if [[ "$is_valid_json" == true ]] || [[ "$is_ndjson" == true ]] || [[ "$is_json_content_type" == true && "$looks_like_json" == true ]]; then
        echo "🔍 JSON detected - opening in jqp (press 'q' to quit)"
        sleep 1
        cat "$temp_output" | jqp
    else
        cat "$temp_output"
    fi
    
    # Clean up temporary files
    rm -f "$temp_output" "$temp_headers"
    return $curl_exit_code
}

# Curl with verbose network analysis using tshark/wireshark
# Captures network traffic, shows protocols and packets being exchanged
curl_with_wireshark() {
    # Check if tshark is available
    if ! command -v tshark >/dev/null 2>&1; then
        echo "❌ tshark is not available. Install it with: brew install wireshark"
        echo "   Falling back to regular curl..."
        command curl "$@"
        return $?
    fi

    # Parse arguments to extract the URL and other options
    local url=""
    local curl_args=()
    local interface="any"
    local show_full_packets=false

    # Parse arguments
    for arg in "$@"; do
        case "$arg" in
            --interface=*)
                interface="${arg#*=}"
                ;;
            --full-packets)
                show_full_packets=true
                ;;
            http://*|https://*)
                url="$arg"
                curl_args+=("$arg")
                ;;
            *)
                curl_args+=("$arg")
                ;;
        esac
    done

    # Extract host from URL for filtering
    local host=""
    if [[ -n "$url" ]]; then
        host=$(echo "$url" | sed -E 's|^https?://([^/:]+).*|\1|')
    fi

    # Get sudo access upfront BEFORE any other operations
    echo "🔐 Requesting sudo access for packet capture..."
    if ! sudo -v; then
        echo "❌ Sudo access required for tshark packet capture"
        echo "   Falling back to regular curl..."
        command curl "${curl_args[@]}"
        return $?
    fi
    echo ""

    echo "🔍 Starting network capture with tshark..."
    echo "📡 Interface: $interface"
    if [[ -n "$host" ]]; then
        echo "🎯 Target host: $host"
    fi
    echo ""

    # Create temporary files with unique names
    local pcap_file=$(mktemp -t curlv_capture.XXXXXX.pcap)
    local curl_output=$(mktemp -t curlv_output.XXXXXX)
    local curl_stats=$(mktemp -t curlv_stats.XXXXXX)
    local tshark_pid=""

    # Build tshark capture filter
    local capture_filter=""
    if [[ -n "$host" ]]; then
        capture_filter="host $host"
    fi

    # Start tshark capture in background (sudo session is already authenticated)
    echo "📡 Starting packet capture..."
    if [[ -n "$capture_filter" ]]; then
        sudo tshark -i "$interface" -f "$capture_filter" -w "$pcap_file" -q 2>/dev/null &
    else
        sudo tshark -i "$interface" -w "$pcap_file" -q 2>/dev/null &
    fi
    tshark_pid=$!

    # Wait for tshark to actually start listening (give it more time to initialize)
    sleep 2
    if ! kill -0 "$tshark_pid" 2>/dev/null; then
        echo "❌ Failed to start tshark"
        rm -f "$pcap_file" "$curl_output" "$curl_stats"
        return 1
    fi
    echo "✓ Packet capture started (listening...)"

    # Execute curl and save stats
    echo "🌐 Executing curl request..."
    command curl "${curl_args[@]}" -o "$curl_output" -w "HTTP_CODE=%{http_code}\nTIME_TOTAL=%{time_total}\nTIME_CONNECT=%{time_connect}\nTIME_STARTTRANSFER=%{time_starttransfer}\nSIZE_DOWNLOAD=%{size_download}\nSPEED_DOWNLOAD=%{speed_download}\n" -s > "$curl_stats" 2>&1
    local curl_exit=$?
    echo "✓ Request completed"

    # Give tshark more time to capture all remaining packets (including TCP teardown)
    echo "⏳ Capturing remaining packets..."
    sleep 3

    # Stop tshark gracefully
    echo "🛑 Stopping packet capture..."
    if [[ -n "$tshark_pid" ]] && kill -0 "$tshark_pid" 2>/dev/null; then
        sudo kill -INT "$tshark_pid" 2>/dev/null
        # Wait for tshark to finish writing (give it more time)
        local wait_count=0
        while kill -0 "$tshark_pid" 2>/dev/null && [[ $wait_count -lt 20 ]]; do
            sleep 0.3
            ((wait_count++))
        done
        # Force kill if still running
        if kill -0 "$tshark_pid" 2>/dev/null; then
            sudo kill -9 "$tshark_pid" 2>/dev/null
            sleep 0.5  # Give it a moment to write
        fi
    fi
    echo "✓ Packet capture stopped"
    echo ""

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 PACKET ANALYSIS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check if we captured any packets
    if [[ ! -s "$pcap_file" ]]; then
        echo "⚠️  No packets captured. This could mean:"
        echo "   - The connection was too fast"
        echo "   - Wrong interface selected"
        echo "   - Insufficient permissions"
    else
        # Show protocol hierarchy statistics
        echo ""
        echo "🔬 Protocol Hierarchy:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        tshark -r "$pcap_file" -q -z io,phs 2>/dev/null | tail -n +5

        echo ""
        echo "📊 Protocol Statistics:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        tshark -r "$pcap_file" -q -z conv,tcp 2>/dev/null | head -20

        echo ""
        echo "🔍 Packet Summary:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if [[ "$show_full_packets" == true ]]; then
            # Show detailed packet information
            tshark -r "$pcap_file" -V 2>/dev/null
        else
            # Show summary of packets (protocol, source, destination, info)
            tshark -r "$pcap_file" -T fields -e frame.number -e frame.time_relative -e ip.src -e ip.dst -e _ws.col.Protocol -e _ws.col.Info -E header=y -E separator=\| 2>/dev/null | column -t -s '|'
        fi

        # Show HTTP-specific information if present
        echo ""
        echo "🌐 HTTP Details:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        local http_info=$(tshark -r "$pcap_file" -Y "http" -T fields -e http.request.method -e http.request.uri -e http.response.code -e http.response.phrase 2>/dev/null)
        if [[ -n "$http_info" ]]; then
            echo "$http_info" | while IFS=$'\t' read method uri code phrase; do
                if [[ -n "$method" ]]; then
                    echo "  Request: $method $uri"
                fi
                if [[ -n "$code" ]]; then
                    echo "  Response: $code $phrase"
                fi
            done
        else
            echo "  No HTTP packets captured (possibly HTTPS/TLS encrypted)"
        fi

        # Show TLS/SSL information if present
        echo ""
        echo "🔐 TLS/SSL Details:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        local tls_info=$(tshark -r "$pcap_file" -Y "tls.handshake.type" -T fields -e tls.handshake.type -e tls.handshake.version 2>/dev/null)
        if [[ -n "$tls_info" ]]; then
            echo "  TLS Handshake detected:"
            echo "$tls_info" | while IFS=$'\t' read type version; do
                case "$type" in
                    1) echo "    - Client Hello (TLS version: $version)" ;;
                    2) echo "    - Server Hello (TLS version: $version)" ;;
                    11) echo "    - Certificate" ;;
                    12) echo "    - Server Key Exchange" ;;
                    14) echo "    - Server Hello Done" ;;
                    16) echo "    - Client Key Exchange" ;;
                esac
            done
        else
            echo "  No TLS handshake captured"
        fi

        echo ""
        echo "💾 Capture file saved at: $pcap_file"
        echo "   Use 'wireshark $pcap_file' to analyze in GUI"
        echo "   Use 'tshark -r $pcap_file' for more analysis"
    fi

    # Show HTTP stats
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 HTTP STATISTICS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if [[ -f "$curl_stats" ]]; then
        while IFS='=' read -r key value; do
            case "$key" in
                HTTP_CODE) echo "  HTTP Code: $value" ;;
                TIME_TOTAL) echo "  Time Total: ${value}s" ;;
                TIME_CONNECT) echo "  Time Connect: ${value}s" ;;
                TIME_STARTTRANSFER) echo "  Time Start Transfer: ${value}s" ;;
                SIZE_DOWNLOAD) echo "  Size Download: $value bytes" ;;
                SPEED_DOWNLOAD) echo "  Speed Download: $value bytes/s" ;;
            esac
        done < "$curl_stats"
    fi

    # Show curl output
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 RESPONSE BODY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$curl_output"
    echo ""

    # Clean up temporary files (keep pcap for analysis)
    rm -f "$curl_output" "$curl_stats"

    return $curl_exit
}

