package parser_test

import (
	"github.com/eirini-forks/pipelinechecker/parser"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = DescribeTable("santizing input", func(input, expectedOutput []string) {
	sanitizer := parser.NewSanitizer()
	output := sanitizer.Sanitize(input)
	Expect(output).To(Equal(expectedOutput))
},
	Entry("noop", []string{"hello"}, []string{"hello"}),
	Entry("balanced pair", []string{"  \x08\x08- hello"}, []string{"- hello"}),
	Entry("unbalanced pairs", []string{"   \x08\x08- hello"}, []string{" - hello"}),
)
