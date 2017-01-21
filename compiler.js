/*
  By : Jesse Bergerstock
  Date : 02/19/2016
  Description : A minimal functional language compiler.
*/

/*Dependencies*/
//File Manager Dependency
var fs = require("fs");
//Parser and Lexer Dependency
var Parser = require("jison").Parser;

/*Tools*/
//Get Input txt file with node as second arg after compiler.js
var input = fs.readFileSync(process.argv[2], "utf8");
//Get grammar from local grammar.jison file
var grammar = fs.readFileSync("grammar.jison", "utf8");
//Instantiate parser to generate syntax tree
var parser = new Parser(grammar);

/*Symbol Table*/
//Symbol table tracks all symbols used in program and is the only source of memory.
var symbolTable = {};

/*Syntax Tree*/
//Instantiate syntax tree
var program = parser.parse(input);

/*Functions to Run Program*/
//Expressions
function evalExpression(expression,scope) {
  if (expression.type == "function_call") {
    return callFunction(expression.symbol,expression.arguments);
  } else if (expression.type == "number") {
    return expression.value;
  } else if (expression.type == "identifier") {
    if (scope[expression.symbol] == undefined) {
      throw new Error("Symbol : \"" + expression.symbol + "\" Not yet defined");
    }
    return scope[expression.symbol];
  } else {
    throw new Error("Bad evalExpression " + JSON.stringify(expression));
  }
}
function callFunction(symbol,arguments) {
  let func = symbolTable[symbol];
  let signature = func.signature;
  let expression = func.expression;
  let localScope = {};
  if (signature.length != arguments.length) {
    throw new Error("Bad argument count for function " + JSON.stringify(func));
  }
  //create local scope for function using params and args
  for (let i = 0; i < signature.length; i ++) {
    localScope[signature[i]] = evalExpression(arguments[i],symbolTable);
  }
  return evalExpression(expression,localScope);
}
//Assignments
function defineFunction(symbol,parameters,expression) {
  let func = {};
  func.signature = parameters;
  func.expression = expression;
  symbolTable[symbol] = func;
}
function defineAssignment(symbol,expression) {
  symbolTable[symbol] = evalExpression(expression,symbolTable);
}
//Printing to console
function print(string,expression) {
  console.log(string + evalExpression(expression,symbolTable));
}
function dump() {
  console.log("DUMPING SYMBOL TABLE\n\n", JSON.stringify(symbolTable,null,4));
}
//Statements
function evalStatement(statement) {
  if (statement.type == "function_define") {
    defineFunction(statement.symbol,statement.parameters,statement.expression);
  } else if (statement.type == "assignment") {
    defineAssignment(statement.symbol,statement.expression);
  } else if (statement.type == "print") {
    print(statement.string,statement.expression);
  } else if (statement.type == "dump") {
    dump()
  } else {
    throw new Error(JSON.stringify(statement,null,4));
  }
}

/*Run Code*/
for (let i = 0; i < program.statements.length; i++) {
  evalStatement(program.statements[i]);
}
