open Pos

type size = int [@@deriving show]

type var_name' = string [@@deriving show]
and var_name = var_name' pos_ast [@@deriving show]

type fun_name' = string [@@deriving show]
and fun_name = fun_name' pos_ast [@@deriving show]

type struct_name' = string [@@deriving show]
and struct_name = struct_name' pos_ast [@@deriving show]

type mutability' =
  | R
  | W
  | RW
[@@deriving show]
and mutability = mutability' pos_ast [@@deriving show]

and label' =
  | Public
  | Secret
[@@deriving show]
and label = label' pos_ast [@@deriving show]

and var_attr = { cache_aligned : bool }

and field' =
  | Field of var_name * base_type
[@@deriving show]
and field = field' pos_ast [@@deriving show]
and fields = field list [@@deriving show]

and base_type' =
  | Bool of label
  | UInt of size * label
  | Int of size * label
  | Ref of base_type * mutability
  | Arr of base_type * lexpr * var_attr
  | Struct of fields
  | UVec of size * int * label  (* this is really a special case of Arr[Ref_RW[UInt(size, label)], int] *)
  | String  (* for debug functions *)
[@@deriving show]
and base_type = base_type' pos_ast [@@deriving show]

and lexpr' =
  | LIntLiteral of int
  | LDynamic of var_name
[@@deriving show]
and lexpr = lexpr' pos_ast [@@deriving show]

and expr' =
  (* Blessable *)
  | True
  | False
  | IntLiteral of int
  | Variable of var_name
  | Cast of base_type * expr
  | UnOp of Ast.unop * expr
  | BinOp of Ast.binop * expr * expr
  | TernOp of expr * expr * expr
  | Select of expr * expr * expr  (* ct version of TernOp *)
  | Declassify of expr
  (* Non-blessable *)
  | Enref of var_name
  | Deref of expr
  | ArrayGet of expr * lexpr
  | ArrayLit of expr list
  | ArrayZeros of lexpr
  | ArrayCopy of expr
  | ArrayView of expr * lexpr * lexpr
  | Shuffle of expr * int list
  | StructLit of (var_name * expr) list
  | StructGet of expr * var_name
  (* Auxilliary *)
  | Inject of var_name * statements  (* only generated by transform *)
  | CheckedExpr of statements * expr  (* generated by smack *)
  | PostCheckedExpr of expr * statements  (* generated by smack *)
  | StringLiteral of string
[@@deriving show]
and expr = (expr' pos_ast) * (base_type' pos_ast) [@@deriving show]

and cond = expr [@@deriving show]
and thenblock = block [@@deriving show]
and elseblock = block [@@deriving show]

and args = expr list [@@deriving show]
and block = statements [@@deriving show]

and statement' =
  | Block of block
  | VarDec of var_name * base_type * expr
  | FnCall of var_name * base_type * fun_name * args
  | VoidFnCall of fun_name * args
  | Assign of expr * expr
  | If of cond * thenblock * elseblock
  | RangeFor of var_name * base_type * expr * expr * block
  | ArrayFor of var_name * base_type * expr * block
  | Return of expr
  | VoidReturn
  | Assume of expr
[@@deriving show]
and statement = statement' pos_ast [@@deriving show]
and statements = statement list [@@deriving show]

and param' =
  | Param of var_name * base_type
[@@deriving show]
and param = param' pos_ast [@@deriving show]
and params = param list [@@deriving show]

and ret_type = base_type option [@@deriving show]

and fn_type = { export : bool; inline : inline; everhi : bool }
and inline =
  | Default
  | Always
  | Never

and function_dec' =
  | FunDec of fun_name * fn_type * ret_type * params * block
  | CExtern of fun_name * ret_type * params
[@@deriving show]
and function_dec = function_dec' pos_ast [@@deriving show]
and function_decs = function_dec list [@@deriving show]

and struct_type' =
  | StructDef of struct_name * fields
and struct_type = struct_type' pos_ast [@@deriving show]

and structs = struct_type list
[@@deriving show]

and fact_module =
  | Module of structs * function_decs
[@@deriving show]

let default_var_attr = { cache_aligned=false; }
