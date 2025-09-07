package main

import (
	"fmt"
	"strings"
	"time"
)

type User struct {
	Name     string
	Age      int
	Email    string
	IsActive bool
}

func (u User) GetDisplayName() string {
	return fmt.Sprintf("%s (%d years old)", u.Name, u.Age)
}

func (u User) IsAdult() bool {
	return u.Age >= 18
}

func (u *User) Activate() {
	u.IsActive = true
}

func main() {
	user := User{
		Name:     "Alice",
		Age:      25,
		Email:    "alice@example.com",
		IsActive: false,
	}

	// Test struct method completion:
	// Type "user." and you should see: GetDisplayName(), IsAdult(), Activate(), Name, Age, Email, IsActive
	message := user.GetDisplayName()
	
	// Test package completion:
	// Type "fmt." and you should see: Printf(), Println(), Sprintf(), etc.
	fmt.Println(message)
	
	// Type "strings." and you should see: ToUpper(), ToLower(), Contains(), etc.
	upperMessage := strings.ToUpper(message)
	fmt.Println(upperMessage)
	
	// Type "time." and you should see: Now(), Sleep(), Second, etc.
	currentTime := time.Now()
	fmt.Printf("Current time: %v\n", currentTime)
	
	// Test if user is adult
	if user.IsAdult() {
		fmt.Println("User is an adult")
	}
	
	// Activate user
	user.Activate()
	fmt.Printf("User active status: %v\n", user.IsActive)
}