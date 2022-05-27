package parser_test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"github.com/eirini-forks/pipelinechecker/parser"
)

const (
	fakePassword = "fake-password"
)

var (
	simpleMatch = []string{
		"- fieldA: something",
		"+ fieldA: fake-password",
	}

	simpleNonMatch = []string{
		"- fieldA: something",
		"+ fieldB: fake-password",
	}

	tryToTrickIt = []string{
		"- fieldA: something",
		"+ fieldA: somethingElse",
	}

	matchedButWeird = []string{
		"- fieldA: something",
		"- fieldB: something",
		"+ fieldC: fake-password",
		"+ fieldA: fake-password",
		"+ fieldB: fake-password",
		"- fieldC: something",
	}

	groupToProp = []string{
		"- fieldA:",
		"+ fieldA: something",
	}

	singleAddition = []string{
		"+ hello: there",
	}

	colonInValue = []string{
		"- hello: aaaaaaa:something",
		"+ hello: fake-password:something",
	}
)

var _ = DescribeTable("FieldChecker", func(input []string, expectedOutput bool) {
	checker := parser.NewFieldChecker(fakePassword)
	ok := checker.Check(input)
	Expect(ok).To(Equal(expectedOutput))
},
	Entry("simple match", simpleMatch, true),
	Entry("simple non match", simpleNonMatch, false),
	Entry("try to trick it", tryToTrickIt, false),
	Entry("matched group, weird order", matchedButWeird, true),
	Entry("group changed to property", groupToProp, false),
	Entry("just a single addition", singleAddition, false),
	Entry("a colon in the value", colonInValue, true),
)
