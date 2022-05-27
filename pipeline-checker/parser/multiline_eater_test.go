package parser_test

import (
	"github.com/eirini-forks/pipelinechecker/parser"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var multiline1 = []string{
	"- foo: |-",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var multiline2 = []string{
	"- foo: |+",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var multiline3 = []string{
	"- foo: |",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var multiline4 = []string{
	"- foo: |20",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var literalStyle = []string{
	"- foo: >",
	"-   hello",
	"-    there",
	"-   again",
	"+ foo: fake-password",
}

var singleline = []string{
	"- password: mfPcbjd|yv>X2rCXra7fjWetvRgVhN4RaKWGRpoA74mtGrKCjVfE",
	"+ password: fake-password",
}

var _ = DescribeTable("Multiline Chomper", func(input, expectedOutput []string) {
	chomper := parser.NewMultilineChomper()
	output := chomper.Chomp(input)
	Expect(output).To(Equal(expectedOutput))
},
	Entry("multiline", multiline1, []string{"- foo: |-", "+ foo: fake-password"}),
	Entry("multiline", multiline2, []string{"- foo: |+", "+ foo: fake-password"}),
	Entry("multiline", multiline3, []string{"- foo: |", "+ foo: fake-password"}),
	Entry("multiline", multiline4, []string{"- foo: |20", "+ foo: fake-password"}),
	Entry("using a >", literalStyle, []string{"- foo: >", "+ foo: fake-password"}),
	Entry("don't eat single line", singleline, []string{
		"- password: mfPcbjd|yv>X2rCXra7fjWetvRgVhN4RaKWGRpoA74mtGrKCjVfE",
		"+ password: fake-password",
	}),
)
