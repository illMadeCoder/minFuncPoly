var fs = require("fs");
var input = fs.readFileSync(process.argv[2], "utf8");
var Parser = require("jison").Parser;
var grammar = fs.readFileSync("grammar.jison", "utf8");
var parser = new Parser(grammar);
var symbolTable = {};
var abstract_syntax_tree = parser.parse(input);

var file = abstract_syntax_tree;
var statements = file.value;
for (let i = 0; i < statements.length; i++) {
  if (typeof statements[i] == "undefined") {
    continue;
  }
  let statement = statements[i].value;
  if (statement.type == "assignment") {
    let symbol = statement.value.symbol;
    let expr = statement.value.expression;
    if (expr.type == "number") {
      symbolTable[symbol] = expr.value;
    } else if (expr.type == "identifier") {
      symbolTable[symbol] = symbolTable[expr.value];
    }
  }

}
console.log(symbolTable)
