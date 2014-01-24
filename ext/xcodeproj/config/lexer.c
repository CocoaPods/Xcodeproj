
#line 1 "ext/xcodeproj/config/lexer.c.rl"
#include <ctype.h>
#include <ruby.h>

static VALUE mLexer;
// Token metadata keys.
static VALUE sType, sToken, sLineNumber, sCharacterNumber;
// Token types.
static VALUE sInclude, sComment, sSetting, sString, sSpace, sValue;

#ifdef HAVE_RUBY_ENCODING_H
#include <ruby/encoding.h>
#define ENCODED_STR_NEW(ptr, len) rb_enc_str_new(ptr, len, rb_utf8_encoding())
#else
#define ENCODED_STR_NEW(ptr, len) rb_str_new(ptr, len)
#endif

#define GET_TOKEN() ENCODED_STR_NEW(ts, p-ts)
#define EMIT_TOKEN(name) EMIT(name, GET_TOKEN())

#define INIT_LEXER() \
  VALUE string = StringValue(input); \
  char *data   = RSTRING_PTR(string); \
  size_t len   = RSTRING_LEN(string) + 1; \
  int cs       = 0; \
  char *p      = data; \
  char *pe     = data + len; \
  char *ts     = NULL; \
  VALUE result = rb_ary_new();

// ----------------------------------------------------------------------------
// Config lexer
// ----------------------------------------------------------------------------

#define EMIT(type, value) \
  VALUE element = rb_hash_new(); \
  rb_hash_aset(element, sType, type); \
  rb_hash_aset(element, sToken, value); \
  rb_hash_aset(element, sLineNumber, INT2FIX(line_number)); \
  rb_hash_aset(element, sCharacterNumber, INT2FIX(ts - line_start + 1)); \
  rb_ary_push(result, element);


#line 79 "ext/xcodeproj/config/lexer.c.rl"



#line 50 "ext/xcodeproj/config/lexer.c"
static const char _config_lexer_eof_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 9
};

static const int config_lexer_start = 22;
static const int config_lexer_first_final = 22;
static const int config_lexer_error = 0;

static const int config_lexer_en_main = 22;


#line 82 "ext/xcodeproj/config/lexer.c.rl"

static VALUE
lexer_lex_config(VALUE self, VALUE input)
{
  INIT_LEXER();
  char *eof = 0;
  int line_number  = 1;
  char *line_start = p;
  
#line 74 "ext/xcodeproj/config/lexer.c"
	{
	cs = config_lexer_start;
	}

#line 91 "ext/xcodeproj/config/lexer.c.rl"
  
#line 81 "ext/xcodeproj/config/lexer.c"
	{
	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	switch ( cs ) {
case 22:
	switch( (*p) ) {
		case 35: goto tr35;
		case 47: goto tr36;
		case 95: goto tr37;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr37;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr37;
	} else
		goto tr37;
	goto tr1;
case 0:
	goto _out;
case 1:
	if ( (*p) == 105 )
		goto tr0;
	goto tr1;
case 2:
	if ( (*p) == 110 )
		goto tr2;
	goto tr1;
case 3:
	if ( (*p) == 99 )
		goto tr3;
	goto tr1;
case 4:
	if ( (*p) == 108 )
		goto tr4;
	goto tr1;
case 5:
	if ( (*p) == 117 )
		goto tr5;
	goto tr1;
case 6:
	if ( (*p) == 100 )
		goto tr6;
	goto tr1;
case 7:
	if ( (*p) == 101 )
		goto tr7;
	goto tr1;
case 8:
	if ( (*p) == 32 )
		goto tr8;
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr8;
	goto tr1;
case 9:
	if ( (*p) == 34 )
		goto tr9;
	goto tr1;
case 10:
	if ( (*p) == 34 )
		goto tr11;
	goto tr10;
case 11:
	if ( (*p) == 34 )
		goto tr13;
	goto tr12;
case 12:
	switch( (*p) ) {
		case 0: goto tr14;
		case 10: goto tr14;
		case 13: goto tr15;
	}
	goto tr1;
case 23:
	switch( (*p) ) {
		case 35: goto tr38;
		case 47: goto tr39;
		case 95: goto tr40;
	}
	if ( (*p) < 65 ) {
		if ( 48 <= (*p) && (*p) <= 57 )
			goto tr40;
	} else if ( (*p) > 90 ) {
		if ( 97 <= (*p) && (*p) <= 122 )
			goto tr40;
	} else
		goto tr40;
	goto tr1;
case 13:
	if ( (*p) == 47 )
		goto tr16;
	goto tr1;
case 14:
	switch( (*p) ) {
		case 0: goto tr18;
		case 10: goto tr18;
		case 13: goto tr20;
		case 32: goto tr19;
	}
	if ( 9 <= (*p) && (*p) <= 12 )
		goto tr19;
	goto tr17;
case 15:
	switch( (*p) ) {
		case 0: goto tr22;
		case 10: goto tr22;
		case 13: goto tr23;
	}
	goto tr21;
case 16:
	switch( (*p) ) {
		case 32: goto tr24;
		case 61: goto tr26;
		case 95: goto tr25;
	}
	if ( (*p) < 48 ) {
		if ( 9 <= (*p) && (*p) <= 13 )
			goto tr24;
	} else if ( (*p) > 57 ) {
		if ( (*p) > 90 ) {
			if ( 97 <= (*p) && (*p) <= 122 )
				goto tr25;
		} else if ( (*p) >= 65 )
			goto tr25;
	} else
		goto tr25;
	goto tr1;
case 17:
	switch( (*p) ) {
		case 32: goto tr27;
		case 61: goto tr28;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr27;
	goto tr1;
case 18:
	switch( (*p) ) {
		case 0: goto tr1;
		case 10: goto tr28;
		case 32: goto tr30;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr30;
	goto tr29;
case 19:
	switch( (*p) ) {
		case 0: goto tr32;
		case 10: goto tr32;
		case 13: goto tr33;
	}
	goto tr31;
case 20:
	switch( (*p) ) {
		case 0: goto tr32;
		case 10: goto tr32;
		case 13: goto tr34;
		case 32: goto tr30;
	}
	if ( 9 <= (*p) && (*p) <= 12 )
		goto tr30;
	goto tr29;
case 21:
	if ( (*p) == 10 )
		goto tr14;
	goto tr1;
	}

	tr1: cs = 0; goto _again;
	tr35: cs = 1; goto _again;
	tr38: cs = 1; goto f8;
	tr0: cs = 2; goto _again;
	tr2: cs = 3; goto _again;
	tr3: cs = 4; goto _again;
	tr4: cs = 5; goto _again;
	tr5: cs = 6; goto _again;
	tr6: cs = 7; goto _again;
	tr7: cs = 8; goto _again;
	tr8: cs = 9; goto _again;
	tr9: cs = 10; goto _again;
	tr12: cs = 11; goto _again;
	tr10: cs = 11; goto f0;
	tr11: cs = 12; goto f1;
	tr13: cs = 12; goto f2;
	tr36: cs = 13; goto _again;
	tr39: cs = 13; goto f8;
	tr16: cs = 14; goto _again;
	tr19: cs = 14; goto f0;
	tr20: cs = 14; goto f3;
	tr21: cs = 15; goto _again;
	tr17: cs = 15; goto f0;
	tr23: cs = 15; goto f4;
	tr25: cs = 16; goto _again;
	tr37: cs = 16; goto f0;
	tr40: cs = 16; goto f9;
	tr27: cs = 17; goto _again;
	tr24: cs = 17; goto f5;
	tr28: cs = 18; goto _again;
	tr26: cs = 18; goto f5;
	tr31: cs = 19; goto _again;
	tr29: cs = 19; goto f0;
	tr33: cs = 19; goto f6;
	tr30: cs = 20; goto f0;
	tr34: cs = 20; goto f7;
	tr15: cs = 21; goto _again;
	tr14: cs = 23; goto _again;
	tr18: cs = 23; goto f3;
	tr22: cs = 23; goto f4;
	tr32: cs = 23; goto f6;

f0:
#line 45 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;
f4:
#line 46 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sComment); }
	goto _again;
f2:
#line 47 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sInclude); }
	goto _again;
f5:
#line 48 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sSetting); }
	goto _again;
f8:
#line 50 "ext/xcodeproj/config/lexer.c.rl"
	{
    line_number++;
    line_start = p;
  }
	goto _again;
f6:
#line 55 "ext/xcodeproj/config/lexer.c.rl"
	{
    char *te = p;
    // Trim leading space
    while (te > ts && isspace(*(te-1))) te--;
    // Trim 1 leading semicolon, if it exists
    if (*(te-1) == ';') te--;
    EMIT(sValue, ENCODED_STR_NEW(ts, te-ts));
  }
	goto _again;
f3:
#line 45 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
#line 46 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sComment); }
	goto _again;
f1:
#line 45 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
#line 47 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sInclude); }
	goto _again;
f7:
#line 45 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
#line 55 "ext/xcodeproj/config/lexer.c.rl"
	{
    char *te = p;
    // Trim leading space
    while (te > ts && isspace(*(te-1))) te--;
    // Trim 1 leading semicolon, if it exists
    if (*(te-1) == ';') te--;
    EMIT(sValue, ENCODED_STR_NEW(ts, te-ts));
  }
	goto _again;
f9:
#line 50 "ext/xcodeproj/config/lexer.c.rl"
	{
    line_number++;
    line_start = p;
  }
#line 45 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	switch ( _config_lexer_eof_actions[cs] ) {
	case 9:
#line 50 "ext/xcodeproj/config/lexer.c.rl"
	{
    line_number++;
    line_start = p;
  }
	break;
#line 380 "ext/xcodeproj/config/lexer.c"
	}
	}

	_out: {}
	}

#line 92 "ext/xcodeproj/config/lexer.c.rl"
  return result;
}


// ----------------------------------------------------------------------------
// Build setting value lexer
// ----------------------------------------------------------------------------

#undef EMIT
#define EMIT(type, value) \
  VALUE element = rb_hash_new(); \
  rb_hash_aset(element, sType, type); \
  rb_hash_aset(element, sToken, value); \
  rb_hash_aset(element, sCharacterNumber, INT2FIX(ts - data + 1)); \
  rb_ary_push(result, element);


#line 144 "ext/xcodeproj/config/lexer.c.rl"



#line 409 "ext/xcodeproj/config/lexer.c"
static const int value_lexer_start = 34;
static const int value_lexer_first_final = 34;
static const int value_lexer_error = 0;

static const int value_lexer_en_main = 34;


#line 147 "ext/xcodeproj/config/lexer.c.rl"

static VALUE
lexer_lex_value(VALUE self, VALUE input)
{
  INIT_LEXER();
  
#line 424 "ext/xcodeproj/config/lexer.c"
	{
	cs = value_lexer_start;
	}

#line 153 "ext/xcodeproj/config/lexer.c.rl"
  
#line 431 "ext/xcodeproj/config/lexer.c"
	{
	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	switch ( cs ) {
case 34:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr4;
		case 36: goto tr5;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr4;
	goto tr2;
case 1:
	switch( (*p) ) {
		case 0: goto tr1;
		case 32: goto tr1;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr1;
	goto tr0;
case 2:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr4;
		case 36: goto tr5;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr4;
	goto tr2;
case 35:
	goto tr66;
case 0:
	goto _out;
case 3:
	if ( (*p) == 32 )
		goto tr7;
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr7;
	goto tr6;
case 4:
	switch( (*p) ) {
		case 0: goto tr1;
		case 32: goto tr1;
		case 40: goto tr8;
		case 123: goto tr9;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr1;
	goto tr0;
case 5:
	switch( (*p) ) {
		case 0: goto tr11;
		case 32: goto tr11;
		case 41: goto tr0;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr11;
	goto tr10;
case 6:
	switch( (*p) ) {
		case 0: goto tr13;
		case 32: goto tr13;
		case 41: goto tr14;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr13;
	goto tr12;
case 7:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr15;
		case 36: goto tr16;
		case 41: goto tr17;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr15;
	goto tr10;
case 8:
	switch( (*p) ) {
		case 32: goto tr19;
		case 41: goto tr20;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr19;
	goto tr18;
case 9:
	switch( (*p) ) {
		case 0: goto tr13;
		case 32: goto tr13;
		case 40: goto tr21;
		case 41: goto tr14;
		case 123: goto tr22;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr13;
	goto tr12;
case 10:
	switch( (*p) ) {
		case 0: goto tr11;
		case 32: goto tr11;
		case 41: goto tr14;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr11;
	goto tr10;
case 11:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr23;
		case 36: goto tr5;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr23;
	goto tr2;
case 12:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr4;
		case 36: goto tr25;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr4;
	goto tr24;
case 13:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr23;
		case 36: goto tr5;
		case 40: goto tr26;
		case 123: goto tr27;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr23;
	goto tr2;
case 14:
	switch( (*p) ) {
		case 0: goto tr29;
		case 32: goto tr29;
		case 125: goto tr0;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr29;
	goto tr28;
case 15:
	switch( (*p) ) {
		case 0: goto tr31;
		case 32: goto tr31;
		case 125: goto tr14;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr31;
	goto tr30;
case 16:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr32;
		case 36: goto tr33;
		case 125: goto tr17;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr32;
	goto tr28;
case 17:
	switch( (*p) ) {
		case 32: goto tr35;
		case 125: goto tr20;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr35;
	goto tr34;
case 18:
	switch( (*p) ) {
		case 0: goto tr31;
		case 32: goto tr31;
		case 40: goto tr36;
		case 123: goto tr37;
		case 125: goto tr14;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr31;
	goto tr30;
case 19:
	switch( (*p) ) {
		case 0: goto tr39;
		case 32: goto tr39;
		case 41: goto tr30;
		case 125: goto tr40;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr39;
	goto tr38;
case 20:
	switch( (*p) ) {
		case 0: goto tr42;
		case 32: goto tr42;
		case 41: goto tr43;
		case 125: goto tr44;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr42;
	goto tr41;
case 21:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr45;
		case 36: goto tr46;
		case 41: goto tr47;
		case 125: goto tr48;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr45;
	goto tr38;
case 22:
	switch( (*p) ) {
		case 32: goto tr50;
		case 41: goto tr51;
		case 125: goto tr52;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr50;
	goto tr49;
case 23:
	switch( (*p) ) {
		case 0: goto tr42;
		case 32: goto tr42;
		case 40: goto tr53;
		case 41: goto tr43;
		case 123: goto tr54;
		case 125: goto tr44;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr42;
	goto tr41;
case 24:
	switch( (*p) ) {
		case 0: goto tr39;
		case 32: goto tr39;
		case 41: goto tr43;
		case 125: goto tr40;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr39;
	goto tr38;
case 25:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr55;
		case 36: goto tr33;
		case 125: goto tr17;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr55;
	goto tr28;
case 26:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr32;
		case 36: goto tr57;
		case 125: goto tr58;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr32;
	goto tr56;
case 27:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr55;
		case 36: goto tr33;
		case 40: goto tr59;
		case 123: goto tr60;
		case 125: goto tr17;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr55;
	goto tr28;
case 28:
	switch( (*p) ) {
		case 0: goto tr29;
		case 32: goto tr29;
		case 125: goto tr14;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr29;
	goto tr28;
case 29:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr61;
		case 36: goto tr16;
		case 41: goto tr17;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr61;
	goto tr10;
case 30:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr15;
		case 36: goto tr63;
		case 41: goto tr58;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr15;
	goto tr62;
case 31:
	switch( (*p) ) {
		case 0: goto tr3;
		case 32: goto tr61;
		case 36: goto tr16;
		case 40: goto tr64;
		case 41: goto tr17;
		case 123: goto tr65;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr61;
	goto tr10;
case 32:
	switch( (*p) ) {
		case 0: goto tr39;
		case 32: goto tr39;
		case 41: goto tr47;
		case 125: goto tr12;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr39;
	goto tr38;
case 33:
	switch( (*p) ) {
		case 0: goto tr39;
		case 32: goto tr39;
		case 41: goto tr47;
		case 125: goto tr44;
	}
	if ( 9 <= (*p) && (*p) <= 13 )
		goto tr39;
	goto tr38;
	}

	tr66: cs = 0; goto _again;
	tr0: cs = 1; goto _again;
	tr2: cs = 1; goto f1;
	tr1: cs = 2; goto f0;
	tr6: cs = 2; goto f2;
	tr20: cs = 2; goto f6;
	tr7: cs = 3; goto _again;
	tr4: cs = 3; goto f1;
	tr5: cs = 4; goto f1;
	tr8: cs = 5; goto _again;
	tr26: cs = 5; goto f1;
	tr12: cs = 6; goto _again;
	tr10: cs = 6; goto f1;
	tr13: cs = 7; goto f0;
	tr18: cs = 7; goto f2;
	tr11: cs = 7; goto f3;
	tr52: cs = 7; goto f6;
	tr19: cs = 8; goto _again;
	tr15: cs = 8; goto f1;
	tr16: cs = 9; goto f1;
	tr21: cs = 10; goto _again;
	tr64: cs = 10; goto f1;
	tr14: cs = 11; goto f4;
	tr17: cs = 11; goto f5;
	tr24: cs = 11; goto f8;
	tr58: cs = 11; goto f10;
	tr23: cs = 12; goto f7;
	tr25: cs = 13; goto f8;
	tr9: cs = 14; goto _again;
	tr27: cs = 14; goto f1;
	tr30: cs = 15; goto _again;
	tr28: cs = 15; goto f1;
	tr31: cs = 16; goto f0;
	tr34: cs = 16; goto f2;
	tr29: cs = 16; goto f3;
	tr51: cs = 16; goto f6;
	tr35: cs = 17; goto _again;
	tr32: cs = 17; goto f1;
	tr33: cs = 18; goto f1;
	tr36: cs = 19; goto _again;
	tr59: cs = 19; goto f1;
	tr41: cs = 20; goto _again;
	tr38: cs = 20; goto f1;
	tr42: cs = 21; goto f0;
	tr49: cs = 21; goto f2;
	tr39: cs = 21; goto f3;
	tr50: cs = 22; goto _again;
	tr45: cs = 22; goto f1;
	tr46: cs = 23; goto f1;
	tr53: cs = 24; goto _again;
	tr43: cs = 25; goto f4;
	tr47: cs = 25; goto f5;
	tr56: cs = 25; goto f8;
	tr55: cs = 26; goto f7;
	tr57: cs = 27; goto f8;
	tr37: cs = 28; goto _again;
	tr60: cs = 28; goto f1;
	tr44: cs = 29; goto f4;
	tr48: cs = 29; goto f5;
	tr62: cs = 29; goto f8;
	tr40: cs = 29; goto f9;
	tr61: cs = 30; goto f7;
	tr63: cs = 31; goto f8;
	tr22: cs = 32; goto _again;
	tr65: cs = 32; goto f1;
	tr54: cs = 33; goto _again;
	tr3: cs = 35; goto _again;

f1:
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;
f0:
#line 113 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sString);
    // Do not consume the end expr
    p--;
  }
	goto _again;
f2:
#line 119 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    p--;
  }
	goto _again;
f4:
#line 125 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    // TODO modifying cs directly breaks with `ragel -G2`
    cs++;
  }
	goto _again;
f3:
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
#line 113 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sString);
    // Do not consume the end expr
    p--;
  }
	goto _again;
f9:
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
#line 125 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    // TODO modifying cs directly breaks with `ragel -G2`
    cs++;
  }
	goto _again;
f7:
#line 113 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sString);
    // Do not consume the end expr
    p--;
  }
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;
f8:
#line 119 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    p--;
  }
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;
f5:
#line 125 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    // TODO modifying cs directly breaks with `ragel -G2`
    cs++;
  }
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;
f6:
#line 125 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    // TODO modifying cs directly breaks with `ragel -G2`
    cs++;
  }
#line 119 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    p--;
  }
	goto _again;
f10:
#line 125 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    // TODO modifying cs directly breaks with `ragel -G2`
    cs++;
  }
#line 119 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    p--;
  }
#line 111 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	goto _again;

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	_out: {}
	}

#line 154 "ext/xcodeproj/config/lexer.c.rl"
  return result;
}


// ----------------------------------------------------------------------------
// Init
// ----------------------------------------------------------------------------

void
Init_lexer()
{
  VALUE mXcodeproj = rb_define_module("Xcodeproj");
  VALUE cConfig = rb_define_class_under(mXcodeproj, "Config", rb_cObject);
  mLexer = rb_define_module_under(cConfig, "Lexer");

  rb_define_singleton_method(mLexer, "lex_config", lexer_lex_config, 1);
  rb_define_singleton_method(mLexer, "lex_value", lexer_lex_value, 1);

  sType = ID2SYM(rb_intern("type"));
  sToken = ID2SYM(rb_intern("token"));
  sLineNumber = ID2SYM(rb_intern("line_number"));
  sCharacterNumber = ID2SYM(rb_intern("character_number"));

  sComment = ID2SYM(rb_intern("comment"));
  sInclude = ID2SYM(rb_intern("include"));
  sSetting = ID2SYM(rb_intern("setting"));
  sString  = ID2SYM(rb_intern("string"));
  sSpace   = ID2SYM(rb_intern("space"));
  sValue   = ID2SYM(rb_intern("value"));
}
