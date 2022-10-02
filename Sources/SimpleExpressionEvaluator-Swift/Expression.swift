/**
 * MIT License
 *
 * Copyright (c) 2022 vkvashistha (vkvashistha@gmail.com)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import Foundation



public class Expression {
    private static let reservedTokens =
            ["(", ")", "==", "&&", "||", "<", ">", "!", "<=", ">=", "!=", "+", "-", "/", "*"];
    private static let binaryOperators =
            ["==", "&&", "||", "<", ">", "!", "<=", ">=", "!=", "+", "-", "/", "*"];
    private static let unaryOperators = ["!", "-"];
    private static let operatorSymbols = ["(", ")", "=", "&", "|", "<", ">", "!", "+", "/", "*", "-"]

    private var symbolTable : [String:Any?] = [:];
    var left:Expression? = nil;
    var right:Expression? = nil;
    var parent:Expression? = nil;
    var node:String? = nil;

    public init() {

    }
    public init(node:String , symbolTable:[String:Any?]? = nil) {
        if(symbolTable != nil) {
            self.symbolTable = symbolTable!;
        }
        let tokens = tokenize(expression:node);
        if(tokens.count == 1) {
            self.node = tokens[0];
        } else {
            var expressionStack = Stack();
            expressionStack.push(self);
            for token in tokens {
                if(token == "(") {
                    let exp:Expression = Expression();
                    exp.symbolTable = self.symbolTable;
                    var parentExp:Expression? = expressionStack.peek() as? Expression
                    if(parentExp != nil) {
                        if(parentExp!.left == nil) {
                            parentExp!.left = exp;
                        } else {
                            parentExp!.right = exp;
                        }
                        exp.parent = parentExp;
                    }
                    expressionStack.push(exp);

                } else if(token == ")") {
                    expressionStack.pop();
                } else if(Expression.binaryOperators.contains(token)) {
                    (expressionStack.peek() as! Expression).node = token;
                } else if(Expression.unaryOperators.contains(token)) {
                    (expressionStack.peek() as! Expression).node = token;
                } else {
                    if(expressionStack.isEmpty()) {
                        expressionStack.push(Expression(node: token, symbolTable: symbolTable));
                    }
                    let currentExpression:Expression = expressionStack.peek() as! Expression;
                    let exp:Expression = Expression(node: token, symbolTable: symbolTable);
                    if (currentExpression.left == nil && !(currentExpression.node != nil && Expression.unaryOperators.contains(currentExpression.node!))) {
                        currentExpression.left = exp;
                        exp.parent = (expressionStack.peek() as! Expression).left;
                    } else  {
                        currentExpression.right = exp;
                    }
                }
            }
        }
    }

    public static func eval(_ expression:String) -> EvaluationResult {
        return expressionBuilder().build(expression).evaluate()!;
    }

    public static func eval(_ expression:String, _ symbolTable:[String: Any?]) -> EvaluationResult {
        return expressionBuilder().putAll(symbolTable).build(expression).evaluate()!;
    }

    public static func expressionBuilder() -> Builder {
        return Builder();
    }
    private func tokenize(expression : String) -> [String] {
        var tokens : [String] = []
        var operand = ""
        for ch in expression {
            if ch == " " {
                continue;
            }
            let symbol = operand + "\(ch)"
            if (Expression.reservedTokens.contains(symbol)) {
                tokens.append(symbol)
                operand.removeAll()
            } else if (Expression.operatorSymbols.contains("\(ch)") && !operand.isEmpty) {
                tokens.append(operand)
                operand.removeAll()
                operand.append(ch)
            } else if (Expression.reservedTokens.contains(operand) && !Expression.operatorSymbols.contains("\(ch)")) {
                tokens.append(operand)
                operand.removeAll()
                operand.append(ch)
            } else {
                operand.append(ch);
            }
        }

        if(!operand.isEmpty) {
            tokens.append(operand)
        }
        
        return tokens;
    }

    public func evaluate() -> EvaluationResult? {
        if(node == nil) {
            return left!.evaluate();
        } else if(left == nil && right == nil) {
            if(Expression.reservedTokens.contains(node!)) {
                return EvaluationResult(node!);
            } else {
                return EvaluationResult(getValueOfDefault(data:symbolTable, key:node!));
            }
        } else if(Expression.unaryOperators.contains(node!) && left == nil) {
            return EvaluationResult(evaluateUnary(operand: right!.evaluate()!.asString(), _operator: node!)!);
        } else if(Expression.binaryOperators.contains(node!)) {
            return EvaluationResult(evaluateBinary(leftOperand: left!.evaluate()!.asString(), _operator: node!, rightOperand: right!.evaluate()!.asString()));
        }
        return nil;
    }

    private func evaluateBinary(leftOperand:String, _operator:String, rightOperand:String) -> String {
        let leftValue = getValueOfDefault(data:symbolTable, key:leftOperand);
        let rightValue = getValueOfDefault(data:symbolTable, key:rightOperand);
        if (leftValue == "nil" || rightValue == "nil") {
            return "false";
        }

        let regexPattern = "^((?!-0?(\\.0+)?(e|$))-?(0|[1-9]\\d*)?(\\.\\d+)?(?<=\\d)(e-?(0|[1-9]\\d*))?|0x[0-9a-f]+)$";
    
        let areBothOperandNumeric = leftValue.range(of:regexPattern, options: .regularExpression) != nil && (rightValue.range(of:regexPattern, options: .regularExpression) != nil);
        switch (_operator) {
        case "<" :

            return toString(areBothOperandNumeric && (leftValue.toDouble()! < rightValue.toDouble()!))!;


        case "<=" :
            return toString(areBothOperandNumeric && (leftValue.toDouble()! <= rightValue.toDouble()!))!;


        case "==" :
                return toString(leftValue == rightValue)!;


        case "!=" :
                return toString(leftValue != rightValue)!;


        case ">" :
                return toString(areBothOperandNumeric && (leftValue.toDouble()! > rightValue.toDouble()!))!;


        case ">=" :
                return toString(areBothOperandNumeric && (leftValue.toDouble()! >= rightValue.toDouble()!))!;


        case "-" :
                return toString(leftValue.toDouble()! - rightValue.toDouble()!)!;


        case "+" :
                if (areBothOperandNumeric) {
                    return toString(leftValue.toDouble()! + rightValue.toDouble()!)!;
                } else {
                    return "0"
                }

        case "*" :
                if (areBothOperandNumeric) {
                    return toString(leftValue.toDouble()! * rightValue.toDouble()!)!
                } else {
                    return "0"
                }

        case "/" :
                if (areBothOperandNumeric) {
                    return toString(leftValue.toDouble()! / rightValue.toDouble()!)!
                } else {
                    return "0"
                }

        case "&&" :
            return toString(leftValue.toBoolean()! && Bool(rightValue)!)!;

        case "||" :
            return toString(leftValue.toBoolean()! || rightValue.toBoolean()!)!

        default :
                return "";
        }
    }

    private func evaluateUnary(operand:String, _operator:String) -> String? {
        if (_operator == "!") {
            return toString(!operand.toBoolean()!);
        } else if (_operator == "-") {
            return "-" + operand;
        }
        return nil;
    }

    private func getValueOfDefault(data:[String: Any?], key:String) -> String {
        if (key.hasPrefix("$")) {
            if ("$currentTimeStamp" == key) {
                return String(describing:(Int(NSDate().timeIntervalSince1970)*1000))
            } else {
                return getValueOfDefault(data:data, key:key.replacingOccurrences(of: "$", with: "", options: .literal, range: nil));
            }
        }
        if (data.keys.contains(key)) {
            if data[key] != nil
            {
                let value = data[key] as Any
                return toString(value) ?? key
                
            } else  {
                return key
            }
        } else {
            return key;
        }
    }

    private func toString(_ value : Any) -> String? {
        if(value is String) {
            return (value as! String)
        }
        else if (value is Bool) {
            return (value as! Bool).toString()
        }
        else if (value is Double) {
            return (value as! Double).toString()
        } else if (value is Int) {
            return (value as! Int).toString()
        } else if (value is CLong) {
            return (value as! CLong).toString()
        } else {
            return String(describing: value)
        }
    }
    
    public class EvaluationResult {
        private let result : String;
        public init(_ result : String) {
            self.result = result;
        }

        public func asInt() -> Int {
            return Int(asDouble())
        }

        public func asDouble() -> Double {
            return Double(result)!
        }

        public func asBoolean() -> Bool {
            return Bool(result)!
        }

        public func asString() -> String {
            return result;
        }
    }

    public class Builder {
        private var symbolTable : [String:Any?] = [:]
        public func putSymbol(_ key:String, _ value : Any) -> Builder {
            symbolTable[key] = value;
            return self;
        }

        public func putAll(_ symbolTable : [String: Any?]) -> Builder {
            self.symbolTable += symbolTable;
            return self;
        }

        public func build(_ expression : String) -> Expression {
            return Expression(node: expression, symbolTable: symbolTable);
        }

    }
}

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}


extension String {
    func toDouble() -> Double? {
        return Double(self)
    }
    
    func toBoolean() -> Bool? {
        return Bool(self)
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
}

extension Bool {
    func toString() -> String {
        if(self == true) {
            return "true"
        } else {
            return "false"
        }
    }
}

extension Double {
    func toString() -> String {
        return String(format: "%f", self)
    }
}

extension Int {
    func toString() -> String {
        return String(format: "%d", self)
    }
}

struct Stack {
    private var items: [Any] = []
    
    func peek() -> Any? {
        if(items.isEmpty) {
            return nil
        } else {
            return items.first
        }
    }
    
    mutating func pop() -> Any {
        return items.removeFirst()
    }
  
    mutating func push(_ element: Any) {
        items.insert(element, at: 0)
    }
    
    func isEmpty() -> Bool {
        return items.isEmpty
    }
}
