
#line 1 "ext/xcodeproj/config/lexer.c.rl"
#include <ruby.h>
#include <ctype.h>


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


#line 80 "ext/xcodeproj/config/lexer.c.rl"



#line 51 "ext/xcodeproj/config/lexer.c"
static const char _config_lexer_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 1, 4, 1, 5, 2, 0, 1, 
	2, 0, 2, 2, 0, 5, 2, 4, 
	0
};

static const char _config_lexer_key_offsets[] = {
	0, 0, 1, 2, 3, 4, 5, 6, 
	7, 10, 11, 12, 13, 16, 17, 23, 
	26, 37, 41, 46, 49, 55, 56, 65
};

static const char _config_lexer_trans_keys[] = {
	105, 110, 99, 108, 117, 100, 101, 32, 
	9, 13, 34, 34, 34, 0, 10, 13, 
	47, 0, 10, 13, 32, 9, 12, 0, 
	10, 13, 32, 61, 95, 9, 13, 48, 
	57, 65, 90, 97, 122, 32, 61, 9, 
	13, 0, 10, 32, 9, 13, 0, 10, 
	13, 0, 10, 13, 32, 9, 12, 10, 
	35, 47, 95, 48, 57, 65, 90, 97, 
	122, 35, 47, 95, 48, 57, 65, 90, 
	97, 122, 0
};

static const char _config_lexer_single_lengths[] = {
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 3, 1, 4, 3, 
	3, 2, 3, 3, 4, 1, 3, 3
};

static const char _config_lexer_range_lengths[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	1, 0, 0, 0, 0, 0, 1, 0, 
	4, 1, 1, 0, 1, 0, 3, 3
};

static const char _config_lexer_index_offsets[] = {
	0, 0, 2, 4, 6, 8, 10, 12, 
	14, 17, 19, 21, 23, 27, 29, 35, 
	39, 47, 51, 56, 60, 66, 68, 75
};

static const char _config_lexer_trans_targs[] = {
	2, 0, 3, 0, 4, 0, 5, 0, 
	6, 0, 7, 0, 8, 0, 9, 9, 
	0, 10, 0, 12, 11, 12, 11, 23, 
	23, 21, 0, 14, 0, 23, 23, 14, 
	14, 14, 15, 23, 23, 15, 15, 17, 
	18, 16, 17, 16, 16, 16, 0, 17, 
	18, 17, 0, 0, 18, 20, 20, 19, 
	23, 23, 19, 19, 23, 23, 20, 20, 
	20, 19, 23, 0, 1, 13, 16, 16, 
	16, 16, 0, 1, 13, 16, 16, 16, 
	16, 0, 0
};

static const char _config_lexer_trans_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 16, 1, 5, 0, 0, 
	0, 0, 0, 0, 0, 13, 13, 13, 
	1, 1, 1, 3, 3, 3, 0, 7, 
	7, 0, 7, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 1, 1, 1, 
	11, 11, 11, 0, 11, 11, 19, 1, 
	1, 1, 0, 0, 0, 0, 1, 1, 
	1, 1, 0, 9, 9, 22, 22, 22, 
	22, 0, 0
};

static const char _config_lexer_eof_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 9
};

static const int config_lexer_start = 22;
static const int config_lexer_first_final = 22;
static const int config_lexer_error = 0;

static const int config_lexer_en_main = 22;


#line 83 "ext/xcodeproj/config/lexer.c.rl"

static VALUE
lexer_lex_config(VALUE self, VALUE input)
{
  INIT_LEXER();
  char *eof = 0;
  int line_number  = 1;
  char *line_start = p;
  
#line 147 "ext/xcodeproj/config/lexer.c"
	{
	cs = config_lexer_start;
	}

#line 92 "ext/xcodeproj/config/lexer.c.rl"
  
#line 154 "ext/xcodeproj/config/lexer.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _config_lexer_trans_keys + _config_lexer_key_offsets[cs];
	_trans = _config_lexer_index_offsets[cs];

	_klen = _config_lexer_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _config_lexer_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	cs = _config_lexer_trans_targs[_trans];

	if ( _config_lexer_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _config_lexer_actions + _config_lexer_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 46 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	break;
	case 1:
#line 47 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sComment); }
	break;
	case 2:
#line 48 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sInclude); }
	break;
	case 3:
#line 49 "ext/xcodeproj/config/lexer.c.rl"
	{ EMIT_TOKEN(sSetting); }
	break;
	case 4:
#line 51 "ext/xcodeproj/config/lexer.c.rl"
	{
    line_number++;
    line_start = p;
  }
	break;
	case 5:
#line 56 "ext/xcodeproj/config/lexer.c.rl"
	{
    char *te = p;
    // Trim leading space
    while (te > ts && isspace(*(te-1))) te--;
    // Trim 1 leading semicolon, if it exists
    if (*(te-1) == ';') te--;
    EMIT(sValue, ENCODED_STR_NEW(ts, te-ts));
  }
	break;
#line 261 "ext/xcodeproj/config/lexer.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _config_lexer_actions + _config_lexer_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 4:
#line 51 "ext/xcodeproj/config/lexer.c.rl"
	{
    line_number++;
    line_start = p;
  }
	break;
#line 284 "ext/xcodeproj/config/lexer.c"
		}
	}
	}

	_out: {}
	}

#line 93 "ext/xcodeproj/config/lexer.c.rl"
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



#line 314 "ext/xcodeproj/config/lexer.c"
static const char _value_lexer_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	3, 2, 0, 1, 2, 0, 3, 2, 
	1, 0, 2, 2, 0, 2, 3, 0, 
	2, 3, 2, 3, 3, 2, 0
};

static const unsigned char _value_lexer_key_offsets[] = {
	0, 0, 4, 9, 12, 18, 23, 28, 
	34, 38, 45, 50, 55, 60, 67, 72, 
	77, 83, 87, 94, 100, 106, 113, 118, 
	126, 132, 138, 144, 152, 157, 163, 169, 
	177, 183, 189, 194
};

static const char _value_lexer_trans_keys[] = {
	0, 32, 9, 13, 0, 32, 36, 9, 
	13, 32, 9, 13, 0, 32, 40, 123, 
	9, 13, 0, 32, 41, 9, 13, 0, 
	32, 41, 9, 13, 0, 32, 36, 41, 
	9, 13, 32, 41, 9, 13, 0, 32, 
	40, 41, 123, 9, 13, 0, 32, 41, 
	9, 13, 0, 32, 36, 9, 13, 0, 
	32, 36, 9, 13, 0, 32, 36, 40, 
	123, 9, 13, 0, 32, 125, 9, 13, 
	0, 32, 125, 9, 13, 0, 32, 36, 
	125, 9, 13, 32, 125, 9, 13, 0, 
	32, 40, 123, 125, 9, 13, 0, 32, 
	41, 125, 9, 13, 0, 32, 41, 125, 
	9, 13, 0, 32, 36, 41, 125, 9, 
	13, 32, 41, 125, 9, 13, 0, 32, 
	40, 41, 123, 125, 9, 13, 0, 32, 
	41, 125, 9, 13, 0, 32, 36, 125, 
	9, 13, 0, 32, 36, 125, 9, 13, 
	0, 32, 36, 40, 123, 125, 9, 13, 
	0, 32, 125, 9, 13, 0, 32, 36, 
	41, 9, 13, 0, 32, 36, 41, 9, 
	13, 0, 32, 36, 40, 41, 123, 9, 
	13, 0, 32, 41, 125, 9, 13, 0, 
	32, 41, 125, 9, 13, 0, 32, 36, 
	9, 13, 0
};

static const char _value_lexer_single_lengths[] = {
	0, 2, 3, 1, 4, 3, 3, 4, 
	2, 5, 3, 3, 3, 5, 3, 3, 
	4, 2, 5, 4, 4, 5, 3, 6, 
	4, 4, 4, 6, 3, 4, 4, 6, 
	4, 4, 3, 0
};

static const char _value_lexer_range_lengths[] = {
	0, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 1, 1, 1, 1, 1, 
	1, 1, 1, 0
};

static const unsigned char _value_lexer_index_offsets[] = {
	0, 0, 4, 9, 12, 18, 23, 28, 
	34, 38, 45, 50, 55, 60, 67, 72, 
	77, 83, 87, 94, 100, 106, 113, 118, 
	126, 132, 138, 144, 152, 157, 163, 169, 
	177, 183, 189, 194
};

static const char _value_lexer_indicies[] = {
	1, 1, 1, 0, 3, 4, 5, 4, 
	2, 7, 7, 6, 1, 1, 8, 9, 
	1, 0, 11, 11, 0, 11, 10, 13, 
	13, 14, 13, 12, 3, 15, 16, 17, 
	15, 10, 19, 20, 19, 18, 13, 13, 
	21, 14, 22, 13, 12, 11, 11, 14, 
	11, 10, 3, 23, 5, 23, 2, 3, 
	4, 25, 4, 24, 3, 23, 5, 26, 
	27, 23, 2, 29, 29, 0, 29, 28, 
	31, 31, 14, 31, 30, 3, 32, 33, 
	17, 32, 28, 35, 20, 35, 34, 31, 
	31, 36, 37, 14, 31, 30, 39, 39, 
	30, 40, 39, 38, 42, 42, 43, 44, 
	42, 41, 3, 45, 46, 47, 48, 45, 
	38, 50, 51, 52, 50, 49, 42, 42, 
	53, 43, 54, 44, 42, 41, 39, 39, 
	43, 40, 39, 38, 3, 55, 33, 17, 
	55, 28, 3, 32, 57, 58, 32, 56, 
	3, 55, 33, 59, 60, 17, 55, 28, 
	29, 29, 14, 29, 28, 3, 61, 16, 
	17, 61, 10, 3, 15, 63, 58, 15, 
	62, 3, 61, 16, 64, 17, 65, 61, 
	10, 39, 39, 47, 12, 39, 38, 39, 
	39, 47, 44, 39, 38, 3, 4, 5, 
	4, 2, 66, 0
};

static const char _value_lexer_trans_targs[] = {
	1, 2, 1, 35, 3, 4, 2, 3, 
	5, 14, 6, 7, 6, 7, 11, 8, 
	9, 11, 7, 8, 2, 10, 32, 12, 
	11, 13, 5, 14, 15, 16, 15, 16, 
	17, 18, 16, 17, 19, 28, 20, 21, 
	29, 20, 21, 25, 29, 22, 23, 25, 
	29, 21, 22, 16, 7, 24, 33, 26, 
	25, 27, 11, 19, 28, 30, 29, 31, 
	10, 32, 0
};

static const char _value_lexer_trans_actions[] = {
	0, 3, 1, 0, 1, 1, 5, 0, 
	0, 0, 1, 9, 0, 3, 7, 1, 
	1, 21, 5, 0, 24, 0, 0, 15, 
	18, 18, 1, 1, 1, 9, 0, 3, 
	1, 1, 5, 0, 0, 0, 1, 9, 
	12, 0, 3, 7, 7, 1, 1, 21, 
	21, 5, 0, 24, 24, 0, 0, 15, 
	18, 18, 27, 1, 1, 15, 18, 18, 
	1, 1, 0
};

static const int value_lexer_start = 34;
static const int value_lexer_first_final = 34;
static const int value_lexer_error = 0;

static const int value_lexer_en_main = 34;


#line 147 "ext/xcodeproj/config/lexer.c.rl"

static VALUE
lexer_lex_value(VALUE self, VALUE input)
{
  INIT_LEXER();
  
#line 448 "ext/xcodeproj/config/lexer.c"
	{
	cs = value_lexer_start;
	}

#line 153 "ext/xcodeproj/config/lexer.c.rl"
  
#line 455 "ext/xcodeproj/config/lexer.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _value_lexer_trans_keys + _value_lexer_key_offsets[cs];
	_trans = _value_lexer_index_offsets[cs];

	_klen = _value_lexer_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _value_lexer_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	_trans = _value_lexer_indicies[_trans];
	cs = _value_lexer_trans_targs[_trans];

	if ( _value_lexer_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _value_lexer_actions + _value_lexer_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 112 "ext/xcodeproj/config/lexer.c.rl"
	{ ts = p; }
	break;
	case 1:
#line 114 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sString);
    // Do not consume the end expr
    p--;
  }
	break;
	case 2:
#line 120 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSpace);
    // Do not consume the end expr
    p--;
  }
	break;
	case 3:
#line 126 "ext/xcodeproj/config/lexer.c.rl"
	{
    EMIT_TOKEN(sSetting);
    // Skip over next character.
    cs++;
  }
	break;
#line 557 "ext/xcodeproj/config/lexer.c"
		}
	}

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
