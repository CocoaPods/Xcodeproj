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

%%{
  machine config_lexer;

  action buffer       { ts = p; }
  action emit_comment { EMIT_TOKEN(sComment); }
  action emit_include { EMIT_TOKEN(sInclude); }
  action emit_setting { EMIT_TOKEN(sSetting); }

  action end_of_line {
    line_number++;
    line_start = p;
  }

  action emit_value {
    char *te = p;
    // Trim leading space
    while (te > ts && isspace(*(te-1))) te--;
    // Trim 1 leading semicolon, if it exists
    if (*(te-1) == ';') te--;
    EMIT(sValue, ENCODED_STR_NEW(ts, te-ts));
  }

  ASSIGN     = '=';
  UNDERSCORE = '_';
  DQUOTE     = '"';
  DSLASH     = '//';
  INCLUDE    = '#include';

  EOL        = (0 | '\n' | '\r\n') %end_of_line;
  Whitespace = space* :>> EOL;
  Comment    = DSLASH space* (^EOL* >buffer %emit_comment);
  Include    = INCLUDE space DQUOTE (^DQUOTE* >buffer %emit_include) DQUOTE;
  Setting    = (alnum | UNDERSCORE)+ >buffer %emit_setting;
  Value      = ^EOL+ >buffer %emit_value;
  Assignment = Setting space* ASSIGN space* Value;

  main := ((Comment | Include | Assignment) :>> EOL)*;
}%%

%% write data;

static VALUE
lexer_lex_config(VALUE self, VALUE input)
{
  INIT_LEXER();
  char *eof = 0;
  int line_number  = 1;
  char *line_start = p;
  %% write init;
  %% write exec;
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

%%{
  machine value_lexer;

  action buffer { ts = p; }

  action emit_string {
    EMIT_TOKEN(sString);
    // Do not consume the end expr
    fhold;
  }

  action emit_whitespace {
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    fhold;
  }

  action emit_setting {
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    cs++;
  }

  EOL    = 0;
  PSTART = '$(';
  PEND   = ')';
  CSTART = '${';
  CEND   = '}';

  String       = ^(space | EOL)+ >buffer %emit_string (space | EOL);
  Whitespace   = ^(^space | EOL)+ >buffer %emit_whitespace (^space | EOL);
  SettingParen = PSTART (^PEND+ >buffer %emit_setting) PEND;
  SettingCurly = CSTART (^CEND+ >buffer %emit_setting) CEND;

  main := ((SettingParen | SettingCurly | Whitespace | String)* :>> EOL)?;
}%%

%% write data;

static VALUE
lexer_lex_value(VALUE self, VALUE input)
{
  INIT_LEXER();
  %% write init;
  %% write exec;
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
