package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"time"
)

type User struct {
	ID       int       `json:"id"`
	Name     string    `json:"name"`
	Email    string    `json:"email"`
	Age      int       `json:"age"`
	IsActive bool      `json:"is_active"`
	Created  time.Time `json:"created"`
}

func (u User) GetFullName() string {
	return fmt.Sprintf("%s <%s>", u.Name, u.Email)
}

func (u User) IsAdult() bool {
	return u.Age >= 18
}

func (u *User) Activate() {
	u.IsActive = true
}

func main() {
	// Test 1: fmt package completion
	// Type "fmt." and you should see: Print, Printf, Println, Sprint, Sprintf, etc.
	fmt.Println("Testing Go LSP autocompletion")
	
	// Test 2: strings package completion  
	// Type "strings." and you should see: Contains, HasPrefix, ToUpper, ToLower, etc.
	message := "hello world"
	upperMessage := strings.ToUpper(message)
	
	// Test 3: time package completion
	// Type "time." and you should see: Now, Sleep, Since, Parse, etc.
	now := time.Now()
	
	// Test 4: strconv package completion
	// Type "strconv." and you should see: Atoi, Itoa, ParseInt, FormatInt, etc.
	numStr := strconv.Itoa(42)
	
	// Test 5: os package completion
	// Type "os." and you should see: Getenv, Exit, Create, Open, etc.
	homeDir, _ := os.UserHomeDir()
	
	// Test 6: filepath package completion
	// Type "filepath." and you should see: Join, Base, Dir, Ext, etc.
	fullPath := filepath.Join(homeDir, "documents", "test.txt")
	
	// Test 7: http package completion
	// Type "http." and you should see: Get, Post, NewRequest, etc.
	client := &http.Client{Timeout: 10 * time.Second}
	
	// Test 8: json package completion
	// Type "json." and you should see: Marshal, Unmarshal, NewDecoder, etc.
	user := User{
		ID:       1,
		Name:     "John Doe",
		Email:    "john@example.com",
		Age:      30,
		IsActive: false,
		Created:  now,
	}
	
	// Test 9: struct method completion
	// Type "user." and you should see: GetFullName(), IsAdult(), Activate(), ID, Name, Email, etc.
	fullName := user.GetFullName()
	isAdult := user.IsAdult()
	user.Activate()
	
	// Test 10: context package completion
	// Type "context." and you should see: Background, WithCancel, WithTimeout, etc.
	ctx := context.Background()
	
	// Test 11: regexp package completion
	// Type "regexp." and you should see: Compile, MustCompile, Match, etc.
	pattern := regexp.MustCompile(`\w+`)
	
	// Test 12: log package completion
	// Type "log." and you should see: Print, Printf, Println, Fatal, etc.
	log.Printf("User: %s, Age: %d, Adult: %v", fullName, user.Age, isAdult)
	
	// Output results
	fmt.Printf("Upper message: %s\n", upperMessage)
	fmt.Printf("Current time: %v\n", now)
	fmt.Printf("Number as string: %s\n", numStr)
	fmt.Printf("Home directory: %s\n", homeDir)
	fmt.Printf("Full path: %s\n", fullPath)
	fmt.Printf("HTTP client timeout: %v\n", client.Timeout)
	fmt.Printf("User JSON: %+v\n", user)
	fmt.Printf("Context: %v\n", ctx)
	fmt.Printf("Pattern: %v\n", pattern)
}

// Test function completion
// Type "test" and you should see function suggestions
func testFunction() {
	// Test variable completion
	// After typing some variables, they should appear in completion
	localVar := "test"
	anotherVar := 42
	
	// Type the first few letters of variables to see completion
	fmt.Println(localVar, anotherVar)
}

// Test method completion on interfaces
func testInterfaceCompletion() {
	var w strings.Builder
	// Type "w." and you should see: Write, WriteString, String, etc.
	w.WriteString("Hello")
	result := w.String()
	fmt.Println(result)
}