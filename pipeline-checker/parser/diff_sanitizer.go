package parser

import "strings"

type Sanitizer struct{}

func NewSanitizer() Sanitizer {
	return Sanitizer{}
}

func (s Sanitizer) Sanitize(input []string) []string {
	output := []string{}

	for _, line := range input {
		output = append(output, s.sanitizeLine(line))
	}
	return output
}

func (s Sanitizer) sanitizeLine(line string) string {
	result := line

	for {
		previous := result
		result = strings.ReplaceAll(result, " \x08", "")
		if previous == result {
			break
		}
	}

	return result
}
