from sly import Lexer, Parser
import sys

P = 1234577
P_EXP = P - 1

class CalcLexer(Lexer):
    tokens = { NUM, PLUS, MINUS, TIMES, DIVIDE, POW, LPAREN, RPAREN }
    ignore = ' \t\r'
    ignore_comment = r'\#.*'

    PLUS = r'\+'
    MINUS = r'-'
    TIMES = r'\*'
    DIVIDE = r'/'
    POW = r'\^'
    LPAREN = r'\('
    RPAREN = r'\)'

    @_(r'\\\n')
    def ignore_cont(self, t):
        self.lineno += 1

    @_(r'\d+')
    def NUM(self, t):
        t.value = int(t.value)
        return t

    @_(r'\n')
    def newline(self, t):
        self.lineno += 1

    def error(self, t):
        raise ValueError(f"Unknown character '{t.value[0]}'")


class CalcParser(Parser):
    tokens = CalcLexer.tokens
    
    precedence = (
        ('left', PLUS, MINUS),
        ('left', TIMES, DIVIDE),
        ('nonassoc', POW),
        ('right', UMINUS),
    )

    def norm_p(self, a):
        res = a % P
        if res < 0: res += P
        return res

    def norm_exp(self, a):
        res = a % P_EXP
        if res < 0: res += P_EXP
        return res

    def add(self, a, b):
        return self.norm_p(a + b)

    def sub(self, a, b):
        return self.norm_p(a - b)

    def mult(self, a, b):
        return self.norm_p(a * b)

    def power(self, base, exp):
        base = self.norm_p(base)
        exp = self.norm_exp(exp)
        return pow(base, exp, P)

    def inverse(self, n):
        n = self.norm_p(n)
        if n == 0: raise ZeroDivisionError("Division by zero")
        return pow(n, P - 2, P)

    def concat_rpn(self, s1, s2, op):
        return f"{s1} {s2} {op}"

    def num_to_str(self, val):
        return str(self.norm_p(val))

    @_('expr')
    def line(self, p):
        return p.expr

    @_('expr PLUS expr')
    def expr(self, p):
        val = self.add(p.expr0[0], p.expr1[0])
        rpn = self.concat_rpn(p.expr0[1], p.expr1[1], "+")
        has_pow = p.expr0[2] or p.expr1[2]
        return (val, rpn, has_pow)

    @_('expr MINUS expr')
    def expr(self, p):
        val = self.sub(p.expr0[0], p.expr1[0])
        rpn = self.concat_rpn(p.expr0[1], p.expr1[1], "-")
        has_pow = p.expr0[2] or p.expr1[2]
        return (val, rpn, has_pow)

    @_('expr TIMES expr')
    def expr(self, p):
        val = self.mult(p.expr0[0], p.expr1[0])
        rpn = self.concat_rpn(p.expr0[1], p.expr1[1], "*")
        has_pow = p.expr0[2] or p.expr1[2]
        return (val, rpn, has_pow)

    @_('expr DIVIDE expr')
    def expr(self, p):
        has_pow = p.expr0[2] or p.expr1[2]
        try:
            inv = self.inverse(p.expr1[0])
        except ZeroDivisionError:
            raise ValueError("Division by zero")
        
        val = self.mult(p.expr0[0], inv)
        rpn = self.concat_rpn(p.expr0[1], p.expr1[1], "/")
        return (val, rpn, has_pow)

    @_('expr POW expr')
    def expr(self, p):
        if p.expr0[2] or p.expr1[2]:
            raise ValueError("Nested powers are not allowed")
            
        val = self.power(p.expr0[0], p.expr1[0])
        rpn = self.concat_rpn(p.expr0[1], p.expr1[1], "^")
        return (val, rpn, True)

    @_('MINUS expr %prec UMINUS')
    def expr(self, p):
        val = -p.expr[0]
        rpn = self.num_to_str(val) 
        has_pow = p.expr[2]
        return (val, rpn, has_pow)

    @_('LPAREN expr RPAREN')
    def expr(self, p): 
        return p.expr

    @_('NUM')
    def expr(self, p):
        val = p.NUM
        rpn = self.num_to_str(val)
        return (val, rpn, False)

    def error(self, p):
        if p: raise ValueError(f"Syntax error at '{p.value}'")
        else: raise ValueError("Syntax error: unexpected end of expression")


if __name__ == '__main__':
    lexer = CalcLexer()
    parser = CalcParser()
    
    buffer = ""
    for line in sys.stdin:
        line = line.strip()
        if not line or line.startswith('#'): continue
        
        if line.endswith('\\'):
            buffer += line[:-1] + " "
            continue
        
        full_line = buffer + line
        buffer = ""
        
        try:
            tokens = lexer.tokenize(full_line)
            result = parser.parse(tokens)
            if result:
                print(result[1])
                print(f"Result: {parser.norm_p(result[0])}")
        except Exception as e:
            print(f"Error: {e}")