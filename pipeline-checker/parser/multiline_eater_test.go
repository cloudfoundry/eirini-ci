package parser_test

import (
	"github.com/eirini-forks/pipelinechecker/parser"
	. "github.com/onsi/ginkgo/extensions/table"
	. "github.com/onsi/gomega"
)

var multiline = []string{
	"- foo: |-",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var singleline = []string{
	"- password: mfPcbjdyvX2rCXra7fjWetvRgVhN4RaKWGRpoA74mtGrKCjVfE",
	"+ password: fake-password",
}

var _ = DescribeTable("Multiline Chomper", func(input, expectedOutput []string) {
	chomper := parser.NewMultilineChomper()
	output := chomper.Chomp(input)
	Expect(output).To(Equal(expectedOutput))
},
	Entry("multiline", multiline, []string{"- foo: |-", "+ foo: fake-password"}),
	Entry("don't eat single line", singleline, []string{
		"- password: mfPcbjdyvX2rCXra7fjWetvRgVhN4RaKWGRpoA74mtGrKCjVfE",
		"+ password: fake-password",
	}),
)
