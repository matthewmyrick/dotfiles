package main

import (
	"fmt"
	"strings"
)

type Person struct {
	Name string
	Age  int
}

func (p Person) Greet() string {
	return fmt.Sprintf("Hello, I'm %s", p.Name)
}

func (p Person) IsAdult() bool {
	return p.Age >= 18
}

func main() {
	p := Person{Name: "Alice", Age: 25}

	// Type p. here and you should see Greet(), IsAdult(), Name, Age

	message := p.Greet()
	fmt.Println(message)

	// Type strings. here and you should see all string functions
	upper := strings.ToUpper(message)
	fmt.Println(upper)
}
