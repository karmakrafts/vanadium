parser grammar FerrousParser;

/**
 * @author Alexander Hinze
 * @since 24/09/2022
 */

options {
    tokenVocab = FerrousLexer;
}

// Files
file:
    moduleFile
    | sourceFile
    ;

moduleFile:
    NL*
    module
    (modUseStatement | NL)*?
    EOF?
    ;

module:
    KW_MOD
    (qualifiedIdent | ident)
    ;

modUseStatement:
    KW_USE
    KW_MOD
    (qualifiedIdent | ident)
    ;

sourceFile:
    (decl | NL)*?
    EOF?
    ;

decl:
    modBlock
    | modUseStatement
    | useStatement
    | udt
    | typeAlias
    | externFunction
    | function
    | constructor
    | destructor
    | (protoFunction end)
    | (property end)
    | (field end)
    | (statement end)
    ;

typeAlias:
    KW_TYPE
    ident
    genericParamList?
    OP_ASSIGN
    type
    ;

modBlock:
    attributeList
    accessMod?
    KW_MOD
    (qualifiedIdent | ident)
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

useStatement:
    KW_USE
    (qualifiedIdent | ident)
    (DOUBLE_COLON useList)?
    ;

useList:
    L_BRACE
    NL*?
    useTypeList
    NL*?
    R_BRACE
    ;

useTypeList:
    (useType
    | (useType COMMA NL*?))+?
    ;

useType:
    type
    (KW_AS
    ident)?
    ;

// User defined types
udt:
    enumClass
    | class
    | enum
    | struct
    | interface
    | attrib
    | trait
    ;

enumClassBody:
    L_BRACE
    enumConstantList
    (SEMICOLON
    (decl | NL)*?)?
    R_BRACE
    ;

enumClass:
    attributeList
    accessMod?
    KW_ENUM
    KW_CLASS
    ident
    (COLON typeList)?
    enumClassBody
    ;

class:
    attributeList
    accessMod?
    KW_CLASS
    ident
    genericParamList? // Optional because of chevrons
    (COLON typeList)?
    classBody
    ;

classBody:
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

enumBody:
    L_BRACE
    enumConstantList
    R_BRACE
    ;

enum:
    attributeList
    accessMod?
    KW_ENUM
    ident
    enumBody
    ;

enumConstantList:
    (enumConstant
    | (enumConstant COMMA)
    | NL)*?
    ;

enumConstant:
    (ident
    | (ident COMMA))
    ;

struct:
    attributeList
    accessMod?
    KW_STRUCT
    ident
    genericParamList? // Optional because of chevrons
    (COLON
    typeList)?
    classBody
    ;

interfaceBody:
    L_BRACE
    (decl
    | protoFunction
    | NL)*?
    R_BRACE
    ;

interface:
    attributeList
    accessMod?
    KW_INTERFACE
    ident
    genericParamList? // Optional because of chevrons
    (COLON typeList)?
    interfaceBody
    ;

attribBody:
    L_BRACE
    (decl
    | NL)*?
    R_BRACE
    ;

attrib:
    attributeList
    accessMod?
    KW_ATTRIB
    ident
    genericParamList? // Optional because of chevrons
    (COLON typeList)?
    attribBody
    ;

trait:
    attributeList
    accessMod?
    KW_TRAIT
    ident
    genericParamList? // Optional because of chevrons
    (COLON typeList)?
    classBody
    ;

// Attributes
attributeList:
    (attribUsage end?)*?
    ;

attribUsage:
    AT
    (qualifiedIdent | ident)
    (NL*
    L_PAREN
    NL*
    (namedExprList | exprList)
    NL*
    R_PAREN)?
    ;

// Properties
propertyGetter:
    KW_GET
    NL*?
    (inlineFunctionBody | functionBody)
    ;

propertySetter:
    KW_SET
    NL*?
    L_PAREN
    NL*?
    ident
    NL*?
    R_PAREN
    NL*?
    (inlineFunctionBody | functionBody)
    ;

property:
    attributeList
    accessMod?
    NL*?
    (KW_INL NL*)?
    ident
    NL*?
    COLON
    NL*?
    type
    NL*?
    (inlinePropertyBody | propertyBody)
    ;

inlinePropertyBody:
    ARROW
    expr
    ;

propertyBody:
    L_BRACE
    NL*?
    propertyGetter
    (NL* propertySetter)?
    NL*?
    R_BRACE
    ;

// Fields
field:
    attributeList
    (accessMod
    NL*)?
    (KW_STATIC
    NL*)?
    (storageMod
    NL*)*?
    ident
    NL*?
    COLON
    NL*?
    type
    (NL* OP_ASSIGN NL* expr)?
    ;

// Constructors
constructor:
    accessMod?
    ident
    L_PAREN
    functionParamList
    R_PAREN
    (COLON (thisCall | superCall))?
    (functionBody | inlineFunctionBody)?
    ;

thisCall:
    KW_THIS
    L_PAREN
    exprList
    R_PAREN
    ;

superCall:
    KW_SUPER
    L_PAREN
    exprList
    R_PAREN
    ;

// Destructors
destructor:
    OP_INV
    ident
    L_PAREN
    functionParamList
    R_PAREN
    (functionBody | inlineFunctionBody)?
    ;

// Statements
statement:
    forLoop
    | whileLoop
    | loop
    | panicStatement
    | destructureStatement
    | returnStatement
    | expr
    ;

// Destrucuring statements
destructureStatement:
    KW_LET
    KW_MUT?
    AMP?
    L_BRACKET
    inferredParamList
    R_BRACKET
    OP_ASSIGN
    expr
    ;

inferredParamList:
    (ident
    (COMMA ident)*)?
    ;

// Panic statements
panicStatement:
    KW_CONST?
    KW_PANIC
    L_PAREN
    stringLiteral
    R_PAREN
    ;

// Return statements
returnStatement:
    KW_RETURN
    expr?
    ;

// When expressions
whenExpr:
    KW_WHEN
    expr
    L_BRACE
    (whenBranch | NL)*?
    defaultWhenBranch?
    NL*?
    R_BRACE
    ;

whenBranch:
    exprList
    ARROW
    ((expr end)
    | whenBranchBody)
    ;

defaultWhenBranch:
    UNDERSCORE
    ARROW
    ((expr end)
    | whenBranchBody)
    ;

whenBranchBody:
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

// Loops
loop:
    KW_LOOP
    ((expr end)
    | (L_BRACE
    (decl | NL)*?
    R_BRACE))
    ;

// While loops
whileLoop:
    whileDoLoop
    | simpleWhileLoop
    | doWhileLoop
    ;

simpleWhileLoop:
    whileHead
    ((expr end)
    | whileBody)
    ;

whileBody:
    (L_BRACE
    (decl | NL)*?
    R_BRACE)
    ;

doWhileLoop:
    doStatement
    end?
    whileHead
    ;

whileDoLoop:
    whileHead
    end?
    doStatement
    ;

whileHead:
    KW_WHILE
    NL*?
    (L_PAREN
    NL*?
    expr
    NL*?
    R_PAREN)
    ;

doStatement:
    KW_DO
    NL*?
    ((expr end)
    | doBody)
    ;

doBody:
    (L_BRACE
    (decl | NL)*?
    R_BRACE)
    ;

// For loops
forLoop:
    KW_FOR
    NL*?
    (indexedLoopHead
    | rangedLoopHead)
    ((expr end)
    | (L_BRACE
    (decl | NL)*?
    R_BRACE))
    ;

rangedLoopHead:
    L_PAREN
    NL*?
    ident
    NL*?
    KW_IN
    NL*?
    expr
    NL*?
    R_PAREN
    ;

indexedLoopHead:
    L_PAREN
    NL*?
    letExpr?
    NL*?
    SEMICOLON
    NL*?
    expr?
    NL*?
    SEMICOLON
    NL*?
    expr?
    NL*?
    R_PAREN
    ;

// If expressions
ifExpr:
    KW_CONST?
    NL*
    KW_IF
    NL*
    L_PAREN
    NL*
    expr
    NL*
    R_PAREN
    NL*
    ((decl end)
    | ifBody)
    elseIfExpr*?
    elseExpr?
    ;

elseIfExpr:
    KW_ELSE
    NL*
    KW_IF
    NL*
    L_PAREN
    NL*
    expr
    NL*
    R_PAREN
    NL*
    ((statement end)
    | ifBody)
    ;

elseExpr:
    KW_ELSE
    NL*
    ((statement end)
    | ifBody)
    ;

ifBody:
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

// Functions
functionBody:
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

function:
    protoFunction
    (functionBody | inlineFunctionBody)
    ;

externFunction:
    KW_EXTERN
    NL*?
    protoFunction
    end
    ;

letExpr:
    KW_LET
    NL*?
    (KW_MUT NL*)?
    storageMod*?
    NL*?
    ident
    NL*?
    (COLON type)?
    (OP_ASSIGN expr)?
    ;

inlineFunctionBody:
    ARROW
    expr
    end
    ;

functionIdent:
    binaryOp
    | unaryOp
    | OP_ASSIGN
    | ident
    ;

protoFunction:
    attributeList
    (accessMod
    NL*)?
    (KW_STATIC
    NL*)?
    (functionMod
    NL*)*?
    (callConvMod
    NL*)?
    KW_FUN
    NL*?
    functionIdent
    NL*?
    (genericParamList
    NL*)?
    (L_PAREN
    NL*
    functionParamList
    NL*
    R_PAREN)?
    (COLON NL*? type)?
    ;

functionParamList:
    (functionParam
    | (functionParam COMMA) NL*?)*?
    vaFunctionParam?
    ;

functionParam:
    ident
    COLON
    type
    (OP_ASSIGN expr)?
    ;

vaFunctionParam:
    ident
    COLON
    KW_VAARGS
    (OP_ASSIGN (expr (COMMA expr)*?))?
    ;

// Expressions
namedExpr:
    ident
    OP_ASSIGN
    expr
    ;

namedExprList:
    (namedExpr
    | (namedExpr COMMA))*?
    ;

exprList:
    (expr
    | (expr COMMA))*?
    ;

expr:
    groupedExpr
    | unaryOp expr
    | expr binaryOp expr
    | letExpr
    | ifExpr
    | whenExpr
    | lambdaExpr
    | spreadExpr
    | incrementExpr
    | decrementExpr
    | heapInitExpr
    | stackInitExpr
    | stackAllocExpr
    | sizedSliceExpr
    | sliceInitExpr
    | exhaustiveIfExpr
    | exhaustiveWhenExpr
    | assignmentExpr
    | alignofExpr
    | sizeofExpr
    | callExpr
    | ref
    | literal
    ;

lambdaExpr:
    callConvMod?
    L_PAREN
    functionParamList
    R_PAREN
    L_BRACE
    (decl | NL)*?
    R_BRACE
    ;

assignmentExpr:
    ref
    NL*?
    OP_ASSIGN
    NL*?
    expr
    ;

alignofExpr:
    KW_ALIGNOF
    NL*?
    L_PAREN
    NL*?
    ident
    NL*?
    R_PAREN
    ;

sizeofExpr:
    KW_SIZEOF
    NL*?
    (TRIPLE_DOT NL*)?
    L_PAREN
    NL*?
    ident
    NL*?
    R_PAREN
    ;

spreadExpr:
    TRIPLE_DOT
    expr
    ;

groupedExpr:
    L_PAREN
    expr
    R_PAREN
    ;

// Control flow expressions
exhaustiveIfExpr:
    KW_IF
    expr
    ((decl end)
    | ifBody)
    elseIfExpr*?
    elseExpr
    ;

exhaustiveWhenExpr:
    KW_WHEN
    expr
    L_BRACE
    (whenBranch | NL)*?
    defaultWhenBranch
    NL*?
    R_BRACE
    ;

// Array expressions
sizedSliceExpr:
    L_BRACKET
    (type | sizedSliceExpr)
    COMMA
    intLiteral
    R_BRACKET
    ;

sliceInitExpr:
    L_BRACKET
    exprList
    R_BRACKET
    ;

// stackalloc expressions
stackAllocExpr:
    KW_STACKALLOC
    L_BRACKET
    (type | sizedSliceExpr)
    COMMA
    intLiteral
    R_BRACKET
    ;

// Initialization expressions
heapInitExpr:
    KW_NEW
    (sizedSliceExpr
    | (type?
    L_PAREN
    (namedExprList | exprList)
    R_PAREN))
    ;

stackInitExpr:
    type?
    L_BRACE
    (namedExprList | exprList)
    R_BRACE
    ;

// Call expressions
callExpr:
    (ref binaryRefOp)?
    (qualifiedIdent | ident)
    genericList?
    L_PAREN
    (namedExprList | exprList)
    R_PAREN
    end?
    ;

// Increment/decrement expressions
incrementExpr:
    (ref OP_INCREMENT)
    | (OP_INCREMENT ref)
    ;

decrementExpr:
    (ref OP_DECREMENT)
    | (OP_DECREMENT ref)
    ;

//binaryExpr:
binaryOp:
    OP_SWAP

    | OP_SHORTC_AND
    | OP_SHORTC_OR

    | OP_COMPARE
    | OP_EQ
    | OP_NEQ
    | OP_LEQUAL
    | OP_GEQUAL
    | L_CHEVRON
    | R_CHEVRON

    | AMP
    | PIPE
    | OP_XOR
    | OP_LSH
    | OP_RSH

    | OP_MOD
    | OP_DIV
    | ASTERISK
    | OP_PLUS
    | OP_MINUS

    | OP_SAT_TIMES
    | OP_SAT_DIV
    | OP_SAT_MOD
    | OP_SAT_PLUS
    | OP_SAT_MINUS

    | OP_AND_ASSIGN
    | OP_OR_ASSIGN
    | OP_XOR_ASSIGN
    | OP_LSH_ASSIGN
    | OP_RSH_ASSIGN

    | OP_MOD_ASSIGN
    | OP_DIV_ASSIGN
    | OP_TIMES_ASSIGN
    | OP_PLUS_ASSIGN
    | OP_MINUS_ASSIGN

    | OP_SAT_PLUS_ASSIGN
    | OP_SAT_MINUS_ASSIGN
    | OP_SAT_TIMES_ASSIGN
    | OP_SAT_DIV_ASSIGN
    | OP_SAT_MOD_ASSIGN

    | OP_INV_ASSIGN
    ;

// Unary expressions
unaryOp:
    OP_PLUS
    | OP_MINUS
    | OP_INV
    ;

// References
ref:
    specialRef
    | simpleRef
    | methodRef
    | thisRef
    ;

thisRef:
    KW_THIS
    DOT
    ref
    ;

simpleRef:
    (qualifiedIdent | ident)
    (binaryRefOp refIdent)*?
    ;

refIdent:
    LITERAL_I32
    | ident
    ;

binaryRefOp:
    OP_SAFE_PTR_REF
    | ARROW
    | DOT
    ;

specialRef:
    unaryRefOp
    ref
    ;

unaryRefOp:
    OP_SAFE_DEREF
    | ASTERISK
    | AMP
    ;

methodRef:
    (qualifiedIdent | ident)?
    DOUBLE_COLON
    ident
    ;

// Generics
genericParamList:
    L_CHEVRON
    (genericParam
    | (genericParam COMMA))+
    R_CHEVRON
    ;

genericParam:
    ident
    TRIPLE_DOT?
    (COLON genericExpr)?
    (OP_ASSIGN type)?
    ;

genericExpr:
    genericExpr genericOp genericExpr
    | genericGroupedExpr
    ;

genericGroupedExpr:
    L_PAREN
    genericExpr
    R_PAREN
    ;

genericOp:
    AMP
    | PIPE
    ;

genericList:
    L_CHEVRON
    (type
    | (type COMMA))+
    R_CHEVRON
    ;

// Literals
literal:
    boolLiteral
    | intLiteral
    | floatLiteral
    | stringLiteral
    | LITERAL_CHAR
    | KW_NULL
    | KW_THIS
    ;

boolLiteral:
    KW_TRUE
    | KW_FALSE;

intLiteral:
    sintLiteral
    | uintLiteral
    ;

sintLiteral:
    LITERAL_I8
    | LITERAL_I16
    | LITERAL_I32
    | LITERAL_I64
    | LITERAL_ISIZE
    ;

uintLiteral:
    LITERAL_U8
    | LITERAL_U16
    | LITERAL_U32
    | LITERAL_U64
    | LITERAL_USIZE
    ;

floatLiteral:
    LITERAL_F32
    | LITERAL_F64
    ;

stringLiteral:
    multilineStringLiteral
    | simpleStringLiteral
    ;

simpleStringLiteral:
    (DOUBLE_QUOTE
    (STRING_MODE_TEXT
    | STRING_MODE_ESCAPED_STRING_END
    | STRING_MODE_ESCAPED_CHAR
    | (STRING_MODE_LERP_BEGIN
    expr*?
    R_BRACE))+
    DOUBLE_QUOTE)
    | EMPTY_STRING
    ;

multilineStringLiteral:
    (ML_STRING_BEGIN
    (ML_STRING_MODE_TEXT
    | ML_STRING_MODE_ESCAPED_ML_STRING_END
    | ML_STRING_MODE_ESCAPED_CHAR
    | (ML_STRING_MODE_LERP_BEGIN
    expr*?
    R_BRACE))+
    ML_STRING_END)
    | EMPTY_ML_STRING
    ;

// Modifiers
accessMod:
    (KW_PUB
    L_PAREN
    (KW_MOD
    | (COLON)
    | typeList)
    R_PAREN)
    | KW_PUB
    ;

callConvMod:
    KW_CALLCONV
    L_PAREN
    IDENT
    R_PAREN
    ;

functionMod:
    KW_CONST
    | KW_INL
    | KW_VIRTUAL
    | KW_OVERRIDE
    | KW_OP
    ;

storageMod:
    KW_CONST
    | KW_TLS
    ;

typeMod:
    KW_ATOMIC
    | KW_MUT
    ;

// Types
typeList:
    (type
    | (type COMMA))+?
    ;

type:
    functionType
    | tupleType
    | sliceType
    | genericType
    | simpleType
    ;

tupleType:
    L_PAREN
    typeList
    R_PAREN
    ;

functionType:
    callConvMod?
    (L_PAREN
    typeList?
    (COMMA
    KW_VAARGS)?
    R_PAREN)
    ARROW
    type
    ;

simpleType:
    pointerType
    | refType
    | builtinType
    | qualifiedIdent
    | ident
    ;

refType:
    KW_MUT?
    AMP
    type
    ;

pointerType:
    typeMod*
    ASTERISK+
    type
    ;

genericType:
    simpleType
    genericList
    ;

sliceType:
    L_BRACKET
    type
    R_BRACKET
    ;

builtinType:
    typeMod*?
    (intType
    | floatType
    | miscType)
    ;

miscType:
    KW_VOID
    | KW_BOOL
    | KW_CHAR
    | KW_STRING
    ;

intType:
    sintType
    | uintType
    ;

sintType:
    KW_I8
    | KW_I16
    | KW_I32
    | KW_I64
    | KW_ISIZE
    ;

uintType:
    KW_U8
    | KW_U16
    | KW_U32
    | KW_U64
    | KW_USIZE
    ;

floatType:
    KW_F32
    | KW_F64
    ;

// Identifiers
qualifiedIdent:
    ident
    (DOUBLE_COLON ident)+
    ;

lerpIdent:
    (TOKEN_LERP_BEGIN
    (MACRO_IDENT
    | specialToken)
    R_BRACE)+
    ;

ident:
    lerpIdent
    | UNDERSCORE
    | IDENT
    ;

specialToken:
    DOLLAR
    | COMMA
    | DOUBLE_COLON
    | COLON
    | TRIPLE_DOT
    | DOUBLE_DOT
    | DOT
    ;

end:
    SEMICOLON
    | NL
    | EOF
    ;