/**
 * Documentation:  https://dlang.org/phobos/dmd_transitivevisitor.html
 * Coverage:    https://codecov.io/gh/dlang/dmd/src/master/src/dmd/transitivevisitor.d
 */

module dmd.transitivevisitor;

import dmd.permissivevisitor;
import dmd.tokens;
import dmd.root.rootobject;

import core.stdc.stdio;

/** Visitor that implements the AST traversal logic. The nodes just accept their children.
  */
extern(C++) class ParseTimeTransitiveVisitor(AST) : PermissiveVisitor!AST
{
    alias visit = PermissiveVisitor!AST.visit;
    mixin ParseVisitMethods!AST;
}

/* This mixin implements the AST traversal logic for parse time AST nodes. The same code
 * is used for semantic time AST node traversal, so in order to not duplicate the code,
 * the template mixin is used.
 */
package mixin template ParseVisitMethods(AST)
{

//   Statement Nodes
//===========================================================
    override void visit(AST.ExpStatement s)
    {
        //printf("Visiting ExpStatement\n");
        if (s.exp && s.exp.op == TOK.declaration)
        {
            (cast(AST.DeclarationExp)s.exp).declaration.accept(this);
            return;
        }
        if (s.exp)
            s.exp.accept(this);
    }

    override void visit(AST.CompileStatement s)
    {
        //printf("Visiting CompileStatement\n");
        s.exp.accept(this);
    }

    override void visit(AST.CompoundStatement s)
    {
        //printf("Visiting CompoundStatement\n");
        foreach (sx; *s.statements)
        {
            if (sx)
                sx.accept(this);
        }
    }

    void visitVarDecl(AST.VarDeclaration v)
    {
        //printf("Visiting VarDeclaration\n");
        if (v.type)
            visitType(v.type);
        if (v._init)
        {
            auto ie = v._init.isExpInitializer();
            if (ie && (ie.exp.op == TOK.construct || ie.exp.op == TOK.blit))
                (cast(AST.AssignExp)ie.exp).e2.accept(this);
            else
                v._init.accept(this);
        }
    }

    override void visit(AST.CompoundDeclarationStatement s)
    {
        //printf("Visiting CompoundDeclarationStatement\n");
        foreach (sx; *s.statements)
        {
            auto ds = sx ? sx.isExpStatement() : null;
            if (ds && ds.exp.op == TOK.declaration)
            {
                auto d = (cast(AST.DeclarationExp)ds.exp).declaration;
                assert(d.isDeclaration());
                if (auto v = d.isVarDeclaration())
                    visitVarDecl(v);
                else
                    d.accept(this);
            }
        }
    }

    override void visit(AST.ScopeStatement s)
    {
        //printf("Visiting ScopeStatement\n");
        if (s.statement)
            s.statement.accept(this);
    }

    override void visit(AST.WhileStatement s)
    {
        //printf("Visiting WhileStatement\n");
        s.condition.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.DoStatement s)
    {
        //printf("Visiting DoStatement\n");
        if (s._body)
            s._body.accept(this);
        s.condition.accept(this);
    }

    override void visit(AST.ForStatement s)
    {
        //printf("Visiting ForStatement\n");
        if (s._init)
            s._init.accept(this);
        if (s.condition)
            s.condition.accept(this);
        if (s.increment)
            s.increment.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.ForeachStatement s)
    {
        //printf("Visiting ForeachStatement\n");
        foreach (p; *s.parameters)
            if (p.type)
                visitType(p.type);
        s.aggr.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.ForeachRangeStatement s)
    {
        //printf("Visiting ForeachRangeStatement\n");
        if (s.prm.type)
            visitType(s.prm.type);
        s.lwr.accept(this);
        s.upr.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.IfStatement s)
    {
        //printf("Visiting IfStatement\n");
        if (s.prm && s.prm.type)
            visitType(s.prm.type);
        s.condition.accept(this);
        s.ifbody.accept(this);
        if (s.elsebody)
            s.elsebody.accept(this);
    }

    override void visit(AST.ConditionalStatement s)
    {
        //printf("Visiting ConditionalStatement\n");
        s.condition.accept(this);
        if (s.ifbody)
            s.ifbody.accept(this);
        if (s.elsebody)
            s.elsebody.accept(this);
    }

    void visitArgs(AST.Expressions* expressions, AST.Expression basis = null)
    {
        if (!expressions || !expressions.dim)
            return;
        foreach (el; *expressions)
        {
            if (!el)
                el = basis;
            if (el)
                el.accept(this);
        }
    }

    override void visit(AST.PragmaStatement s)
    {
        //printf("Visiting PragmaStatement\n");
        if (s.args && s.args.dim)
            visitArgs(s.args);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.StaticAssertStatement s)
    {
        //printf("Visiting StaticAssertStatement\n");
        s.sa.accept(this);
    }

    override void visit(AST.SwitchStatement s)
    {
        //printf("Visiting SwitchStatement\n");
        s.condition.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.CaseStatement s)
    {
        //printf("Visiting CaseStatement\n");
        s.exp.accept(this);
        s.statement.accept(this);
    }

    override void visit(AST.CaseRangeStatement s)
    {
        //printf("Visiting CaseRangeStatement\n");
        s.first.accept(this);
        s.last.accept(this);
        s.statement.accept(this);
    }

    override void visit(AST.DefaultStatement s)
    {
        //printf("Visiting DefaultStatement\n");
        s.statement.accept(this);
    }

    override void visit(AST.GotoCaseStatement s)
    {
        //printf("Visiting GotoCaseStatement\n");
        if (s.exp)
            s.exp.accept(this);
    }

    override void visit(AST.ReturnStatement s)
    {
        //printf("Visiting ReturnStatement\n");
        if (s.exp)
            s.exp.accept(this);
    }

    override void visit(AST.SynchronizedStatement s)
    {
        //printf("Visiting SynchronizedStatement\n");
        if (s.exp)
            s.exp.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.WithStatement s)
    {
        //printf("Visiting WithStatement\n");
        s.exp.accept(this);
        if (s._body)
            s._body.accept(this);
    }

    override void visit(AST.TryCatchStatement s)
    {
        //printf("Visiting TryCatchStatement\n");
        if (s._body)
            s._body.accept(this);
        foreach (c; *s.catches)
            visit(c);
    }

    override void visit(AST.TryFinallyStatement s)
    {
        //printf("Visiting TryFinallyStatement\n");
        s._body.accept(this);
        s.finalbody.accept(this);
    }

    override void visit(AST.OnScopeStatement s)
    {
        //printf("Visiting OnScopeStatement\n");
        s.statement.accept(this);
    }

    override void visit(AST.ThrowStatement s)
    {
        //printf("Visiting ThrowStatement\n");
        s.exp.accept(this);
    }

    override void visit(AST.LabelStatement s)
    {
        //printf("Visiting LabelStatement\n");
        if (s.statement)
            s.statement.accept(this);
    }

    override void visit(AST.ImportStatement s)
    {
        //printf("Visiting ImportStatement\n");
        foreach (imp; *s.imports)
            imp.accept(this);
    }

    void visit(AST.Catch c)
    {
        //printf("Visiting Catch\n");
        if (c.type)
            visitType(c.type);
        if (c.handler)
            c.handler.accept(this);
    }

//   Type Nodes
//============================================================

    void visitType(AST.Type t)
    {
        //printf("Visiting Type\n");
        if (!t)
            return;
        if (t.ty == AST.Type.Kind.function_)
        {
            visitFunctionType(cast(AST.TypeFunction)t, null);
            return;
        }
        else
            t.accept(this);
    }

    void visitFunctionType(AST.TypeFunction t, AST.TemplateDeclaration td)
    {
        if (t.next)
            visitType(t.next);
        if (td)
        {
            foreach (p; *td.origParameters)
                p.accept(this);
        }
        visitParameters(t.parameters);
    }

    void visitParameters(AST.Parameters* parameters)
    {
        if (parameters)
        {
            size_t dim = AST.Parameter.dim(parameters);
            foreach(i; 0..dim)
            {
                AST.Parameter fparam = AST.Parameter.getNth(parameters, i);
                fparam.accept(this);
            }
        }
    }

    override void visit(AST.TypeVector t)
    {
        //printf("Visiting TypeVector\n");
        if (!t.basetype)
            return;
        t.basetype.accept(this);
    }

    override void visit(AST.TypeSArray t)
    {
        //printf("Visiting TypeSArray\n");
        t.next.accept(this);
    }

    override void visit(AST.TypeDArray t)
    {
        //printf("Visiting TypeDArray\n");
        t.next.accept(this);
    }

    override void visit(AST.TypeAArray t)
    {
        //printf("Visiting TypeAArray\n");
        t.next.accept(this);
        t.index.accept(this);
    }

    override void visit(AST.TypePointer t)
    {
        //printf("Visiting TypePointer\n");
        if (t.next.ty == AST.Type.Kind.function_)
        {
            visitFunctionType(cast(AST.TypeFunction)t.next, null);
        }
        else
            t.next.accept(this);
    }

    override void visit(AST.TypeReference t)
    {
        //printf("Visiting TypeReference\n");
        t.next.accept(this);
    }

    override void visit(AST.TypeFunction t)
    {
        //printf("Visiting TypeFunction\n");
        visitFunctionType(t, null);
    }

    override void visit(AST.TypeDelegate t)
    {
        //printf("Visiting TypeDelegate\n");
        visitFunctionType(cast(AST.TypeFunction)t.next, null);
    }

    void visitTypeQualified(AST.TypeQualified t)
    {
        //printf("Visiting TypeQualified\n");
        foreach (id; t.idents)
        {
            if (id.dyncast() == DYNCAST.dsymbol)
                (cast(AST.TemplateInstance)id).accept(this);
            else if (id.dyncast() == DYNCAST.expression)
                (cast(AST.Expression)id).accept(this);
            else if (id.dyncast() == DYNCAST.type)
                (cast(AST.Type)id).accept(this);
        }
    }

    override void visit(AST.TypeIdentifier t)
    {
        //printf("Visiting TypeIdentifier\n");
        visitTypeQualified(t);
    }

    override void visit(AST.TypeInstance t)
    {
        //printf("Visiting TypeInstance\n");
        t.tempinst.accept(this);
        visitTypeQualified(t);
    }

    override void visit(AST.TypeTypeof t)
    {
        //printf("Visiting TypeTypeof\n");
        t.exp.accept(this);
        visitTypeQualified(t);
    }

    override void visit(AST.TypeReturn t)
    {
        //printf("Visiting TypeReturn\n");
        visitTypeQualified(t);
    }

    override void visit(AST.TypeTuple t)
    {
        //printf("Visiting TypeTuple\n");
        visitParameters(t.arguments);
    }

    override void visit(AST.TypeSlice t)
    {
        //printf("Visiting TypeSlice\n");
        t.next.accept(this);
        t.lwr.accept(this);
        t.upr.accept(this);
    }

//      Miscellaneous
//========================================================

    override void visit(AST.StaticAssert s)
    {
        //printf("Visiting StaticAssert\n");
        s.exp.accept(this);
        if (s.msg)
            s.msg.accept(this);
    }

    override void visit(AST.EnumMember em)
    {
        //printf("Visiting EnumMember\n");
        if (em.type)
            visitType(em.type);
        if (em.value)
            em.value.accept(this);
    }

//      Declarations
//=========================================================
    void visitAttribDeclaration(AST.AttribDeclaration d)
    {
        if (d.decl)
            foreach (de; *d.decl)
                de.accept(this);
    }

    override void visit(AST.AttribDeclaration d)
    {
        //printf("Visiting AttribDeclaration\n");
        visitAttribDeclaration(d);
    }

    override void visit(AST.StorageClassDeclaration d)
    {
        //printf("Visiting StorageClassDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.DeprecatedDeclaration d)
    {
        //printf("Visiting DeprecatedDeclaration\n");
        d.msg.accept(this);
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.LinkDeclaration d)
    {
        //printf("Visiting LinkDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.CPPMangleDeclaration d)
    {
        //printf("Visiting CPPMangleDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.ProtDeclaration d)
    {
        //printf("Visiting ProtDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.AlignDeclaration d)
    {
        //printf("Visiting AlignDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.AnonDeclaration d)
    {
        //printf("Visiting AnonDeclaration\n");
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.PragmaDeclaration d)
    {
        //printf("Visiting PragmaDeclaration\n");
        if (d.args && d.args.dim)
            visitArgs(d.args);
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    override void visit(AST.ConditionalDeclaration d)
    {
        //printf("Visiting ConditionalDeclaration\n");
        d.condition.accept(this);
        if (d.decl)
            foreach (de; *d.decl)
                de.accept(this);
        if (d.elsedecl)
            foreach (de; *d.elsedecl)
                de.accept(this);
    }

    override void visit(AST.CompileDeclaration d)
    {
        //printf("Visiting compileDeclaration\n");
        d.exp.accept(this);
    }

    override void visit(AST.UserAttributeDeclaration d)
    {
        //printf("Visiting UserAttributeDeclaration\n");
        visitArgs(d.atts);
        visitAttribDeclaration(cast(AST.AttribDeclaration)d);
    }

    void visitFuncBody(AST.FuncDeclaration f)
    {
        //printf("Visiting funcBody\n");
        if (!f.fbody)
            return;
        if (f.frequire)
            f.frequire.accept(this);
        if (f.fensure)
            f.fensure.accept(this);
        f.fbody.accept(this);
    }

    void visitBaseClasses(AST.ClassDeclaration d)
    {
        //printf("Visiting ClassDeclaration\n");
        if (!d || !d.baseclasses.dim)
            return;
        foreach (b; *d.baseclasses)
            visitType(b.type);
    }

    bool visitEponymousMember(AST.TemplateDeclaration d)
    {
        //printf("Visiting EponymousMember\n");
        if (!d.members || d.members.dim != 1)
            return false;
        AST.Dsymbol onemember = (*d.members)[0];
        if (onemember.ident != d.ident)
            return false;

        if (AST.FuncDeclaration fd = onemember.isFuncDeclaration())
        {
            assert(fd.type);
            visitFunctionType(cast(AST.TypeFunction)fd.type, d);
            if (d.constraint)
                d.constraint.accept(this);
            visitFuncBody(fd);

            return true;
        }

        if (AST.AggregateDeclaration ad = onemember.isAggregateDeclaration())
        {
            visitTemplateParameters(d.parameters);
            if (d.constraint)
                d.constraint.accept(this);
            visitBaseClasses(ad.isClassDeclaration());

            if (ad.members)
                foreach (s; *ad.members)
                    s.accept(this);

            return true;
        }

        if (AST.VarDeclaration vd = onemember.isVarDeclaration())
        {
            if (d.constraint)
                return false;
            if (vd.type)
                visitType(vd.type);
            visitTemplateParameters(d.parameters);
            if (vd._init)
            {
                AST.ExpInitializer ie = vd._init.isExpInitializer();
                if (ie && (ie.exp.op == TOK.construct || ie.exp.op == TOK.blit))
                    (cast(AST.AssignExp)ie.exp).e2.accept(this);
                else
                    vd._init.accept(this);

                return true;
            }
        }

        return false;
    }

    void visitTemplateParameters(AST.TemplateParameters* parameters)
    {
        if (!parameters || !parameters.dim)
            return;
        foreach (p; *parameters)
            p.accept(this);
    }

    override void visit(AST.TemplateDeclaration d)
    {
        //printf("Visiting TemplateDeclaration\n");
        if (visitEponymousMember(d))
            return;

        visitTemplateParameters(d.parameters);
        if (d.constraint)
            d.constraint.accept(this);

        foreach (s; *d.members)
            s.accept(this);
    }

    void visitObject(RootObject oarg)
    {
        if (auto t = AST.isType(oarg))
        {
            visitType(t);
        }
        else if (auto e = AST.isExpression(oarg))
        {
            e.accept(this);
        }
        else if (auto v = AST.isTuple(oarg))
        {
            auto args = &v.objects;
            foreach (arg; *args)
                visitObject(arg);
        }
    }

    void visitTiargs(AST.TemplateInstance ti)
    {
        //printf("Visiting tiargs\n");
        if (!ti.tiargs)
            return;
        foreach (arg; *ti.tiargs)
        {
            visitObject(arg);
        }
    }

    override void visit(AST.TemplateInstance ti)
    {
        //printf("Visiting TemplateInstance\n");
        visitTiargs(ti);
    }

    override void visit(AST.TemplateMixin tm)
    {
        //printf("Visiting TemplateMixin\n");
        visitType(tm.tqual);
        visitTiargs(tm);
    }

    override void visit(AST.EnumDeclaration d)
    {
        //printf("Visiting EnumDeclaration\n");
        if (d.memtype)
            visitType(d.memtype);
        if (!d.members)
            return;
        foreach (em; *d.members)
        {
            if (!em)
                continue;
            em.accept(this);
        }
    }

    override void visit(AST.Nspace d)
    {
        //printf("Visiting Nspace\n");
        foreach(s; *d.members)
            s.accept(this);
    }

    override void visit(AST.StructDeclaration d)
    {
        //printf("Visiting StructDeclaration\n");
        if (!d.members)
            return;
        foreach (s; *d.members)
            s.accept(this);
    }

    override void visit(AST.ClassDeclaration d)
    {
        //printf("Visiting ClassDeclaration\n");
        visitBaseClasses(d);
        if (d.members)
            foreach (s; *d.members)
                s.accept(this);
    }

    override void visit(AST.AliasDeclaration d)
    {
        //printf("Visting AliasDeclaration\n");
        if (d.aliassym)
            d.aliassym.accept(this);
        else
            visitType(d.type);
    }

    override void visit(AST.VarDeclaration d)
    {
        //printf("Visiting VarDeclaration\n");
        visitVarDecl(d);
    }

    override void visit(AST.FuncDeclaration f)
    {
        //printf("Visiting FuncDeclaration\n");
        auto tf = cast(AST.TypeFunction)f.type;
        visitType(tf);
        visitFuncBody(f);
    }

    override void visit(AST.FuncLiteralDeclaration f)
    {
        //printf("Visiting FuncLiteralDeclaration\n");
        if (f.type.ty == AST.Terror)
            return;
        AST.TypeFunction tf = cast(AST.TypeFunction)f.type;
        if (!f.inferRetType && tf.next)
            visitType(tf.next);
        visitParameters(tf.parameters);
        AST.CompoundStatement cs = f.fbody.isCompoundStatement();
        AST.Statement s = !cs ? f.fbody : null;
        AST.ReturnStatement rs = s ? s.isReturnStatement() : null;
        if (rs && rs.exp)
            rs.exp.accept(this);
        else
            visitFuncBody(f);
    }

    override void visit(AST.PostBlitDeclaration d)
    {
        //printf("Visiting PostBlitDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.DtorDeclaration d)
    {
        //printf("Visiting DtorDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.StaticCtorDeclaration d)
    {
        //printf("Visiting StaticCtorDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.StaticDtorDeclaration d)
    {
        //printf("Visiting StaticDtorDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.InvariantDeclaration d)
    {
        //printf("Visiting InvariantDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.UnitTestDeclaration d)
    {
        //printf("Visiting UnitTestDeclaration\n");
        visitFuncBody(d);
    }

    override void visit(AST.NewDeclaration d)
    {
        //printf("Visiting NewDeclaration\n");
        visitParameters(d.parameters);
        visitFuncBody(d);
    }

    override void visit(AST.DeleteDeclaration d)
    {
        //printf("Visiting DeleteDeclaration\n");
        visitParameters(d.parameters);
        visitFuncBody(d);
    }

//   Initializers
//============================================================

    override void visit(AST.StructInitializer si)
    {
        //printf("Visiting StructInitializer\n");
        foreach (i, const id; si.field)
            if (auto iz = si.value[i])
                iz.accept(this);
    }

    override void visit(AST.ArrayInitializer ai)
    {
        //printf("Visiting ArrayInitializer\n");
        foreach (i, ex; ai.index)
        {
            if (ex)
                ex.accept(this);
            if (auto iz = ai.value[i])
                iz.accept(this);
        }
    }

    override void visit(AST.ExpInitializer ei)
    {
        //printf("Visiting ExpInitializer\n");
        ei.exp.accept(this);
    }

//      Expressions
//===================================================

    override void visit(AST.ArrayLiteralExp e)
    {
        //printf("Visiting ArrayLiteralExp\n");
        visitArgs(e.elements, e.basis);
    }

    override void visit(AST.AssocArrayLiteralExp e)
    {
        //printf("Visiting AssocArrayLiteralExp\n");
        foreach (i, key; *e.keys)
        {
            key.accept(this);
            ((*e.values)[i]).accept(this);
        }
    }

    override void visit(AST.TypeExp e)
    {
        //printf("Visiting TypeExp\n");
        visitType(e.type);
    }

    override void visit(AST.ScopeExp e)
    {
        //printf("Visiting ScopeExp\n");
        if (e.sds.isTemplateInstance())
            e.sds.accept(this);
    }

    override void visit(AST.NewExp e)
    {
        //printf("Visiting NewExp\n");
        if (e.thisexp)
            e.thisexp.accept(this);
        if (e.newargs && e.newargs.dim)
            visitArgs(e.newargs);
        visitType(e.newtype);
        if (e.arguments && e.arguments.dim)
            visitArgs(e.arguments);
    }

    override void visit(AST.NewAnonClassExp e)
    {
        //printf("Visiting NewAnonClassExp\n");
        if (e.thisexp)
            e.thisexp.accept(this);
        if (e.newargs && e.newargs.dim)
            visitArgs(e.newargs);
        if (e.arguments && e.arguments.dim)
            visitArgs(e.arguments);
        if (e.cd)
            e.cd.accept(this);
    }

    override void visit(AST.TupleExp e)
    {
        //printf("Visiting TupleExp\n");
        if (e.e0)
            e.e0.accept(this);
        visitArgs(e.exps);
    }

    override void visit(AST.FuncExp e)
    {
        //printf("Visiting FuncExp\n");
        e.fd.accept(this);
    }

    override void visit(AST.DeclarationExp e)
    {
        //printf("Visiting DeclarationExp\n");
        if (auto v = e.declaration.isVarDeclaration())
            visitVarDecl(v);
        else
            e.declaration.accept(this);
    }

    override void visit(AST.TypeidExp e)
    {
        //printf("Visiting TypeidExp\n");
        visitObject(e.obj);
    }

    override void visit(AST.TraitsExp e)
    {
        //printf("Visiting TraitExp\n");
        if (e.args)
            foreach (arg; *e.args)
                visitObject(arg);
    }

    override void visit(AST.IsExp e)
    {
        //printf("Visiting IsExp\n");
        visitType(e.targ);
        if (e.tspec)
            visitType(e.tspec);
        if (e.parameters && e.parameters.dim)
            visitTemplateParameters(e.parameters);
    }

    override void visit(AST.UnaExp e)
    {
        //printf("Visiting UnaExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.BinExp e)
    {
        //printf("Visiting BinExp\n");
        e.e1.accept(this);
        e.e2.accept(this);
    }

    override void visit(AST.CompileExp e)
    {
        //printf("Visiting CompileExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.ImportExp e)
    {
        //printf("Visiting ImportExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.AssertExp e)
    {
        //printf("Visiting AssertExp\n");
        e.e1.accept(this);
        if (e.msg)
            e.msg.accept(this);
    }

    override void visit(AST.DotIdExp e)
    {
        //printf("Visiting DotIdExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.DotTemplateInstanceExp e)
    {
        //printf("Visiting DotTemplateInstanceExp\n");
        e.e1.accept(this);
        e.ti.accept(this);
    }

    override void visit(AST.CallExp e)
    {
        //printf("Visiting CallExp\n");
        e.e1.accept(this);
        visitArgs(e.arguments);
    }

    override void visit(AST.PtrExp e)
    {
        //printf("Visiting PtrExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.DeleteExp e)
    {
        //printf("Visiting DeleteExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.CastExp e)
    {
        //printf("Visiting CastExp\n");
        if (e.to)
            visitType(e.to);
        e.e1.accept(this);
    }

    override void visit(AST.IntervalExp e)
    {
        //printf("Visiting IntervalExp\n");
        e.lwr.accept(this);
        e.upr.accept(this);
    }

    override void visit(AST.ArrayExp e)
    {
        //printf("Visiting ArrayExp\n");
        e.e1.accept(this);
        visitArgs(e.arguments);
    }

    override void visit(AST.PostExp e)
    {
        //printf("Visiting PostExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.PreExp e)
    {
        //printf("Visiting PreExp\n");
        e.e1.accept(this);
    }

    override void visit(AST.CondExp e)
    {
        //printf("Visiting CondExp\n");
        e.econd.accept(this);
        e.e1.accept(this);
        e.e2.accept(this);
    }

// Template Parameter
//===========================================================

    override void visit(AST.TemplateTypeParameter tp)
    {
        //printf("Visiting TemplateTypeParameter\n");
        if (tp.specType)
            visitType(tp.specType);
        if (tp.defaultType)
            visitType(tp.defaultType);
    }

    override void visit(AST.TemplateThisParameter tp)
    {
        //printf("Visiting TemplateThisParameter\n");
        visit(cast(AST.TemplateTypeParameter)tp);
    }

    override void visit(AST.TemplateAliasParameter tp)
    {
        //printf("Visiting TemplateAliasParameter\n");
        if (tp.specType)
            visitType(tp.specType);
        if (tp.specAlias)
            visitObject(tp.specAlias);
        if (tp.defaultAlias)
            visitObject(tp.defaultAlias);
    }

    override void visit(AST.TemplateValueParameter tp)
    {
        //printf("Visiting TemplateValueParameter\n");
        visitType(tp.valType);
        if (tp.specValue)
            tp.specValue.accept(this);
        if (tp.defaultValue)
            tp.defaultValue.accept(this);
    }

//===========================================================

    override void visit(AST.StaticIfCondition c)
    {
        //printf("Visiting StaticIfCondition\n");
        c.exp.accept(this);
    }

    override void visit(AST.Parameter p)
    {
        //printf("Visiting Parameter\n");
        visitType(p.type);
        if (p.defaultArg)
            p.defaultArg.accept(this);
    }

    override void visit(AST.Module m)
    {
        //printf("Visiting Module\n");
        foreach (s; *m.members)
        {
           s.accept(this);
        }
    }
}
