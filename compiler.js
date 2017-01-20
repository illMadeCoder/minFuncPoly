var fs = require("fs");
var input = fs.readFileSync(process.argv[2], "utf8");
var Parser = require("jison").Parser;
var grammar = fs.readFileSync("grammar.jison", "utf8");
var parser = new Parser(grammar);
var symbolTable = {};
parser.yy.syntax_tree = [];
parser.parse(input);
let syntax_tree = parser.yy.syntax_tree;
for (let i = 0; i < syntax_tree.length; i++) {
  //Bottom up parser, look backwards
  let tree = syntax_tree[syntax_tree.length - 1 - i];
  if (tree.type == "expr") {
    if (tree.arg[0].type == "assignment") {
      let id = tree.arg[0].arg[0].arg[0];
      let num = tree.arg[0].arg[1].arg[0];
      symbolTable[id] = num;
    } else if (tree.arg[0].type == "print") {
      let variable = tree.arg[0].arg[0];
      if (variable.type == 'number') {
        console.log(variable.arg[0]);
      } else {
        console.log(symbolTable[variable.arg[0]])
      }
    }
  }
}
