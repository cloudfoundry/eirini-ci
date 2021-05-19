package parser

import "regexp"

type MultilineChomper struct{}

func NewMultilineChomper() MultilineChomper {
	return MultilineChomper{}
}

func (e MultilineChomper) Chomp(input []string) []string {
	output := []string{}

	hasPipe := regexp.MustCompile(`: +[>|]`)
	getSpaces := regexp.MustCompile(`[-+]( *)\S`)

	state := "out"
	indent := 0

	for _, line := range input {
		switch state {
		case "out":
			if hasPipe.MatchString(line) {
				state = "entered"
			}
			output = append(output, line)

		case "entered":
			match := getSpaces.FindStringSubmatch(line)
			indent = len(match[1])
			state = "in"

		case "in":
			match := getSpaces.FindStringSubmatch(line)
			if len(match[1]) < indent {
				state = "out"
				output = append(output, line)
			}
		}
	}

	return output
}
