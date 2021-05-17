package parser

import (
	"fmt"
	"regexp"
	"strings"
)

type FieldChecker struct {
	fakePassword string
}

func NewFieldChecker(fakePassword string) FieldChecker {
	return FieldChecker{
		fakePassword: fakePassword,
	}
}

var fieldValueRegex = regexp.MustCompile(`^[-+] *(\S+?):\s*(\S*)`)

func (c FieldChecker) Check(input []string) bool {
	fields := map[string]int{}

	replacedValueRegex := regexp.MustCompile(fmt.Sprintf(".*%s.*", c.fakePassword))
	for _, line := range input {
		fieldName, fieldValue := parseFieldValue(line)
		if fieldName == "" {
			continue
		}

		if strings.HasPrefix(line, "-") {
			fields[fieldName]--
			continue
		}

		if replacedValueRegex.MatchString(fieldValue) {

			fields[fieldName]++
			continue
		}

		return false
	}

	for _, v := range fields {
		if v != 0 {
			return false
		}
	}

	return true
}

func parseFieldValue(line string) (string, string) {
	submatches := fieldValueRegex.FindStringSubmatch(line)
	if submatches == nil {
		return "", ""
	}

	return submatches[1], submatches[2]
}
