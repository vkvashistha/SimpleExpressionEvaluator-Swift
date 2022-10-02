//
//  File.swift
//  
//
//  Created by Vivek Vashistha on 01/10/22.
//

import Foundation
import XCTest
import SimpleExpressionEvaluator_Swift

public class ExpressionTest : XCTestCase {
    public func testMathOperators() {
        XCTAssertEqual(5, Expression.eval("2+3").asInt());
        XCTAssertEqual(1, Expression.eval("3-2").asInt());
        XCTAssertEqual(6, Expression.eval("2*3").asInt());
        XCTAssertEqual(2, Expression.eval("4/2").asInt());
    }

    public func testPureInequalityComparisonForPositiveNumbers() {
        XCTAssertEqual("false", Expression.eval("2>3").asString());
        XCTAssertEqual("true", Expression.eval("3>2").asString());
        XCTAssertEqual("false", Expression.eval("2>2").asString());
        XCTAssertEqual("true", Expression.eval("2<3").asString());
        XCTAssertEqual("false", Expression.eval("3<2").asString());
        XCTAssertEqual("false", Expression.eval("3<3").asString());
    }

    public func testImpureInequalityComparisonForPositiveNumbers() {
        XCTAssertEqual("false", Expression.eval("2>=3").asString());
        XCTAssertEqual("true", Expression.eval("3>=2").asString());
        XCTAssertEqual("true", Expression.eval("2>=2").asString());
        XCTAssertEqual("true", Expression.eval("2<=3").asString());
        XCTAssertEqual("false", Expression.eval("3<=2").asString());
        XCTAssertEqual("true", Expression.eval("3<=3").asString());
    }

    // Test Case Failing
    public func testNegativeNumberComparison() {
        XCTAssertEqual("false", Expression.eval("-3>2").asString());
        XCTAssertEqual("true", Expression.eval("(3)>(-2)").asString());
    }

    public func testCompoundedAndExpression() {
        XCTAssertEqual("false", Expression.eval("(2>3)&&(3>2)").asString());
        XCTAssertEqual("false", Expression.eval("(3>2)&&(2>3)").asString());
        XCTAssertEqual("true", Expression.eval("(2<3)&&(3>2)").asString());
        XCTAssertEqual("true", Expression.eval("((2<3)&&(3>2))").asString());
    }

    public func testCompoundedORExpression() {
        XCTAssertEqual("true", Expression.eval("(2>3)||(3>2)").asString());
        XCTAssertEqual("true", Expression.eval("(3>2)||(2>3)").asString());
        XCTAssertEqual("false", Expression.eval("(2>3)||(3<2)").asString());
        XCTAssertEqual("true", Expression.eval("(2<3)||(3>2)").asString());
    }

    public func testCompoundedAndORExpression() {
        XCTAssertEqual("true", Expression.eval("((2>3)&&(3>2))||((2>3)||(3>2))").asString());
        XCTAssertEqual("true", Expression.eval("((3>2)&&(2>3))||((3>2)||(2>3))").asString());
        XCTAssertEqual("true", Expression.eval("((2<3)&&(3>2))||((2>3)||(3<2))").asString());
        XCTAssertEqual("true", Expression.eval("((2<3)&&(3>2))||((2<3)||(3>2))").asString());
        XCTAssertEqual("false", Expression.eval("((3>2)&&(2>3))||((2>3)||(3<2))").asString());
    }

    public func testCompoundedLogicalExpressionAndLiterals() {
        XCTAssertEqual("true", Expression.eval("((2>3)&&(3>2))||true").asString());
        XCTAssertEqual("false", Expression.eval("(3>2)&&false").asString());
    }

    // Test Case Failing
    public func testCompoundedLogicalExpressionAndMathematicalExpression() {

        XCTAssertEqual("false", Expression.eval("(2+(1+1))>5").asString());
        XCTAssertEqual("true", Expression.eval("(2+(1+1))>3").asString());
    }

    public func testLogicalExpressionWithSymbolTable() {
        var st:[String:Any?] = [:]
        st["a"] = "2"
        st["b"] = "3"
//        XCTAssertEqual("false", Expression.eval("(a>b)",st).asString());
        XCTAssertEqual("true", Expression.eval("(b>a)",st).asString());
        XCTAssertEqual("true", Expression.eval("(a>b)||(b>a)",st).asString());
        XCTAssertEqual("true", Expression.eval("(b>a)||(a>b)",st).asString());
        XCTAssertEqual("false", Expression.eval("(a>b)||(b<a)",st).asString());
        XCTAssertEqual("true", Expression.eval("(a<b)||(b>a)",st).asString());
    }
}
