package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
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

func (u User) GetDisplayName() string {
	return fmt.Sprintf("%s (%d)", u.Name, u.Age)
}

func (u User) IsAdult() bool {
	return u.Age >= 18
}

func (u *User) SetActive(active bool) {
	u.IsActive = active
}

func main() {
	user := User{
		ID:       1,
		Name:     "John Doe",
		Email:    "john@example.com",
		Age:      30,
		IsActive: false,
		Created:  time.Now(),
	}

	// INTELLISENSE TEST CASES:
	
	// 1. Type "fmt." - should show all fmt functions
	fmt.Println("Testing IntelliSense")
	
	// 2. Type "strings." - should show all string functions
	message := strings.ToUpper("hello world")
	
	// 3. Type "user." - should show all User methods and fields
	displayName := user.GetDisplayName()
	isAdult := user.IsAdult()
	user.SetActive(true)
	
	// 4. Type "time." - should show all time functions
	now := time.Now()
	duration := time.Since(user.Created)
	
	// 5. Type "json." - should show all json functions
	userData, _ := json.Marshal(user)
	
	// 6. Type "strconv." - should show all strconv functions
	ageStr := strconv.Itoa(user.Age)
	
	// 7. Type "os." - should show all os functions  
	hostname, _ := os.Hostname()
	
	// 8. Type "log." - should show all log functions
	log.Printf("User: %s, Adult: %v", displayName, isAdult)
	
	// 9. Type "http." - should show all http functions
	client := &http.Client{
		Timeout: 30 * time.Second,
	}
	
	// 10. Type "context." - should show all context functions
	ctx := context.WithValue(context.Background(), "user", user.ID)
	
	// Print results
	fmt.Printf("Message: %s\n", message)
	fmt.Printf("Display Name: %s\n", displayName)
	fmt.Printf("Is Adult: %v\n", isAdult) 
	fmt.Printf("Now: %v\n", now)
	fmt.Printf("Duration: %v\n", duration)
	fmt.Printf("User Data: %s\n", userData)
	fmt.Printf("Age String: %s\n", ageStr)
	fmt.Printf("Hostname: %s\n", hostname)
	fmt.Printf("Client Timeout: %v\n", client.Timeout)
	fmt.Printf("Context: %v\n", ctx)
}