" Please do not edit this file directly, instead modify polyglot.vim or scripts/build

" Line continuation is used here, remove 'C' from 'cpoptions'
let s:cpo_save = &cpo
set cpo&vim

func! polyglot#Shebang()
  if getline(1) =~# "^#!"
    let ft = polyglot#ShebangFiletype()
    if ft != ""
      let &ft = ft
    endif
  endif

  if &ft == ""
    runtime! scripts.vim
  endif

  return &ft != ""
endfunc

let s:r_hashbang = '^#!\s*\(\S\+\)\s*\(.*\)\s*'
let s:r_envflag = '%(\S\+=\S\+\|-[iS]\|--ignore-environment\|--split-string\)'
let s:r_env = '^\%(\' . s:r_envflag . '\s\+\)*\(\S\+\)'

func! polyglot#ShebangFiletype()
  let l:line1 = getline(1)

  if l:line1 !~# "^#!"
    return
  endif

  let l:pathrest = matchlist(l:line1, s:r_hashbang)

  if len(l:pathrest) == 0
    return
  endif

  let [_, l:path, l:rest; __] = l:pathrest

  let l:script = split(l:path, "/")[-1]

  if l:script == "env"
    let l:argspath = matchlist(l:rest, s:r_env)
    if len(l:argspath) == 0
      return
    endif

    let l:script = l:argspath[1]
  endif

  if has_key(s:interpreters, l:script)
    return s:interpreters[l:script]
  endif

  for interpreter in keys(s:interpreters)
    if l:script =~# '^' . interpreter
      return s:interpreters[interpreter]
    endif
  endfor
endfunc

let s:interpreters = {
  \ 'osascript': 'applescript',
  \ 'tcc': 'c',
  \ 'coffee': 'coffee',
  \ 'crystal': 'crystal',
  \ 'dart': 'dart',
  \ 'elixir': 'elixir',
  \ 'escript': 'erlang',
  \ 'fish': 'fish',
  \ 'gnuplot': 'gnuplot',
  \ 'groovy': 'groovy',
  \ 'runhaskell': 'haskell',
  \ 'chakra': 'javascript',
  \ 'd8': 'javascript',
  \ 'gjs': 'javascript',
  \ 'js': 'javascript',
  \ 'node': 'javascript',
  \ 'nodejs': 'javascript',
  \ 'qjs': 'javascript',
  \ 'rhino': 'javascript',
  \ 'v8': 'javascript',
  \ 'v8-shell': 'javascript',
  \ 'julia': 'julia',
  \ 'lua': 'lua',
  \ 'moon': 'moon',
  \ 'ocaml': 'ocaml',
  \ 'ocamlrun': 'ocaml',
  \ 'ocamlscript': 'ocaml',
  \ 'cperl': 'perl',
  \ 'perl': 'perl',
  \ 'php': 'php',
  \ 'swipl': 'prolog',
  \ 'yap': 'prolog',
  \ 'pwsh': 'ps1',
  \ 'python': 'python',
  \ 'python2': 'python',
  \ 'python3': 'python',
  \ 'qmake': 'qmake',
  \ 'Rscript': 'r',
  \ 'racket': 'racket',
  \ 'perl6': 'raku',
  \ 'raku': 'raku',
  \ 'rakudo': 'raku',
  \ 'ruby': 'ruby',
  \ 'macruby': 'ruby',
  \ 'rake': 'ruby',
  \ 'jruby': 'ruby',
  \ 'rbx': 'ruby',
  \ 'scala': 'scala',
  \ 'ash': 'sh',
  \ 'bash': 'sh',
  \ 'dash': 'sh',
  \ 'ksh': 'sh',
  \ 'mksh': 'sh',
  \ 'pdksh': 'sh',
  \ 'rc': 'sh',
  \ 'sh': 'sh',
  \ 'zsh': 'sh',
  \ 'boolector': 'smt2',
  \ 'cvc4': 'smt2',
  \ 'mathsat5': 'smt2',
  \ 'opensmt': 'smt2',
  \ 'smtinterpol': 'smt2',
  \ 'smt-rat': 'smt2',
  \ 'stp': 'smt2',
  \ 'verit': 'smt2',
  \ 'yices2': 'smt2',
  \ 'z3': 'smt2',
  \ 'deno': 'typescript',
  \ 'ts-node': 'typescript',
\ }

func! polyglot#DetectInpFiletype()
  let line = getline(nextnonblank(1))
  if line =~# '^\*'
    set ft=abaqus | return
  endif
  for lnum in range(1, min([line("$"), 500]))
    let line = getline(lnum)
    if line =~? '^header surface data'
      set ft=trasys | return
    endif
  endfor
endfunc

func! polyglot#DetectAsaFiletype()
  if exists("g:filetype_asa")
    let &ft = g:filetype_asa | return
  endif
  set ft=aspvbs | return
endfunc

func! polyglot#DetectAspFiletype()
  if exists("g:filetype_asp")
    let &ft = g:filetype_asp | return
  endif
  for lnum in range(1, min([line("$"), 3]))
    let line = getline(lnum)
    if line =~? 'perlscript'
      set ft=aspperl | return
    endif
  endfor
  set ft=aspvbs | return
endfunc

func! polyglot#DetectHFiletype()
  for lnum in range(1, min([line("$"), 200]))
    let line = getline(lnum)
    if line =~# '^\s*\(@\(interface\|class\|protocol\|property\|end\|synchronised\|selector\|implementation\)\(\<\|\>\)\|#import\s\+.\+\.h[">]\)'
      if exists("g:c_syntax_for_h")
        set ft=objc | return
      endif
      set ft=objcpp | return
    endif
  endfor
  if exists("g:c_syntax_for_h")
    set ft=c | return
  endif
  if exists("g:ch_syntax_for_h")
    set ft=ch | return
  endif
  set ft=cpp | return
endfunc

func! polyglot#DetectMFiletype()
  let saw_comment = 0
  for lnum in range(1, min([line("$"), 100]))
    let line = getline(lnum)
    if line =~# '^\s*/\*'
      let saw_comment = 1
    endif
    if line =~# '^\s*\(@\(interface\|class\|protocol\|property\|end\|synchronised\|selector\|implementation\)\(\<\|\>\)\|#import\s\+.\+\.h[">]\)'
      set ft=objc | return
    endif
    if line =~# '^\s*%'
      set ft=octave | return
    endif
    if line =~# '^\s*(\*'
      set ft=mma | return
    endif
    if line =~? '^\s*\(\(type\|var\)\(\<\|\>\)\|--\)'
      set ft=murphi | return
    endif
  endfor
  if saw_comment
    set ft=objc | return
  endif
  if exists("g:filetype_m")
    let &ft = g:filetype_m | return
  endif
  set ft=octave | return
endfunc

func! polyglot#DetectFsFiletype()
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '^\(: \|new-device\)'
      set ft=forth | return
    endif
    if line =~# '^\s*\(#light\|import\|let\|module\|namespace\|open\|type\)'
      set ft=fsharp | return
    endif
    if line =~# '\s*\(#version\|precision\|uniform\|varying\|vec[234]\)'
      set ft=glsl | return
    endif
  endfor
  if exists("g:filetype_fs")
    let &ft = g:filetype_fs | return
  endif
  set ft=forth | return
endfunc

func! polyglot#DetectReFiletype()
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '^\s*#\%(\%(if\|ifdef\|define\|pragma\)\s\+\w\|\s*include\s\+[<"]\|template\s*<\)'
      set ft=cpp | return
    endif
    set ft=reason | return
  endfor
endfunc

func! polyglot#DetectIdrFiletype()
  for lnum in range(1, min([line("$"), 5]))
    let line = getline(lnum)
    if line =~# '^\s*--.*[Ii]dris \=1'
      set ft=idris | return
    endif
    if line =~# '^\s*--.*[Ii]dris \=2'
      set ft=idris2 | return
    endif
  endfor
  for lnum in range(1, min([line("$"), 30]))
    let line = getline(lnum)
    if line =~# '^pkgs =.*'
      set ft=idris | return
    endif
    if line =~# '^depends =.*'
      set ft=idris2 | return
    endif
    if line =~# '^%language \(TypeProviders\|ElabReflection\)'
      set ft=idris | return
    endif
    if line =~# '^%language PostfixProjections'
      set ft=idris2 | return
    endif
    if line =~# '^%access .*'
      set ft=idris | return
    endif
  endfor
  if exists("g:filetype_idr")
    let &ft = g:filetype_idr | return
  endif
  set ft=idris2 | return
endfunc

func! polyglot#DetectLidrFiletype()
  for lnum in range(1, min([line("$"), 200]))
    let line = getline(lnum)
    if line =~# '^>\s*--.*[Ii]dris \=1'
      set ft=lidris | return
    endif
  endfor
  set ft=lidris2 | return
endfunc

func! polyglot#DetectBasFiletype()
  for lnum in range(1, min([line("$"), 5]))
    let line = getline(lnum)
    if line =~? 'VB_Name\|Begin VB\.\(Form\|MDIForm\|UserControl\)'
      set ft=vb | return
    endif
  endfor
  set ft=basic | return
endfunc

func! polyglot#DetectPmFiletype()
  let line = getline(nextnonblank(1))
  if line =~# 'XPM2'
    set ft=xpm2 | return
  endif
  if line =~# 'XPM'
    set ft=xpm | return
  endif
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '^\s*\%(use\s\+v6\(\<\|\>\)\|\(\<\|\>\)module\(\<\|\>\)\|\(\<\|\>\)\%(my\s\+\)\=class\(\<\|\>\)\)'
      set ft=raku | return
    endif
    if line =~# '\(\<\|\>\)use\s\+\%(strict\(\<\|\>\)\|v\=5\.\)'
      set ft=perl | return
    endif
  endfor
  if exists("g:filetype_pm")
    let &ft = g:filetype_pm | return
  endif
  set ft=perl | return
endfunc

func! polyglot#DetectPlFiletype()
  let line = getline(nextnonblank(1))
  if line =~# '^[^#]*:-' || line =~# '^\s*\%(%\|/\*\)' || line =~# '\.\s*$'
    set ft=prolog | return
  endif
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '^\s*\%(use\s\+v6\(\<\|\>\)\|\(\<\|\>\)module\(\<\|\>\)\|\(\<\|\>\)\%(my\s\+\)\=class\(\<\|\>\)\)'
      set ft=raku | return
    endif
    if line =~# '\(\<\|\>\)use\s\+\%(strict\(\<\|\>\)\|v\=5\.\)'
      set ft=perl | return
    endif
  endfor
  if exists("g:filetype_pl")
    let &ft = g:filetype_pl | return
  endif
  set ft=perl | return
endfunc

func! polyglot#DetectTFiletype()
  for lnum in range(1, min([line("$"), 5]))
    let line = getline(lnum)
    if line =~# '^\.'
      set ft=nroff | return
    endif
  endfor
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '^\s*\%(use\s\+v6\(\<\|\>\)\|\(\<\|\>\)module\(\<\|\>\)\|\(\<\|\>\)\%(my\s\+\)\=class\(\<\|\>\)\)'
      set ft=raku | return
    endif
    if line =~# '\(\<\|\>\)use\s\+\%(strict\(\<\|\>\)\|v\=5\.\)'
      set ft=perl | return
    endif
  endfor
  if exists("g:filetype_t")
    let &ft = g:filetype_t | return
  endif
  set ft=perl | return
endfunc

func! polyglot#DetectTt2Filetype()
  for lnum in range(1, min([line("$"), 3]))
    let line = getline(lnum)
    if line =~? '<\%(!DOCTYPE HTML\|[%?]\|html\)'
      set ft=tt2html | return
    endif
  endfor
  set ft=tt2 | return
endfunc

func! polyglot#DetectHtmlFiletype()
  let line = getline(nextnonblank(1))
  if line =~# '^\(%\|<[%&].*>\)'
    set ft=mason | return
  endif
  for lnum in range(1, min([line("$"), 50]))
    let line = getline(lnum)
    if line =~# '{%-\=\s*\(end.*\|extends\|block\|macro\|set\|if\|for\|include\|trans\)\(\<\|\>\)\|{#\s\+'
      set ft=htmldjango | return
    endif
    if line =~# '\(\<\|\>\)DTD\s\+XHTML\s'
      set ft=xhtml | return
    endif
  endfor
  set ft=html | au! BufWritePost <buffer> ++once call polyglot#DetectHtmlFiletype()
  return
endfunc


" Restore 'cpoptions'
let &cpo = s:cpo_save
unlet s:cpo_save

""" ftdetect/polyglot.vim

" don't spam the user when Vim is started in Vi compatibility mode
let s:cpo_save = &cpo
set cpo&vim

" Disable all native vim ftdetect
if exists('g:polyglot_test')
  autocmd!
endif

func! s:Observe(fn)
  let b:polyglot_observe = a:fn
  augroup polyglot-observer
    au! CursorHold,CursorHoldI,BufWritePost <buffer>
      \ execute('if polyglot#' . b:polyglot_observe . '() | au! polyglot-observer | endif')
  augroup END
endfunc

let s:disabled_packages = {}
let s:new_polyglot_disabled = []

if exists('g:polyglot_disabled')
  for pkg in g:polyglot_disabled
    let base = split(pkg, '\.')
    if len(base) > 0
      let s:disabled_packages[pkg] = 1
      call add(s:new_polyglot_disabled, base[0]) 
    endif
  endfor
else
  let g:polyglot_disabled_not_set = 1
endif

function! s:SetDefault(name, value)
  if !exists(a:name)
    let {a:name} = a:value
  endif
endfunction

call s:SetDefault('g:markdown_enable_spell_checking', 0)
call s:SetDefault('g:markdown_enable_input_abbreviations', 0)
call s:SetDefault('g:markdown_enable_mappings', 0)

" Enable jsx syntax by default
call s:SetDefault('g:jsx_ext_required', 0)

" Needed for sql highlighting
call s:SetDefault('g:javascript_sql_dialect', 'sql')

" Make csv loading faster
call s:SetDefault('g:csv_start', 1)
call s:SetDefault('g:csv_end', 2)

" Disable json concealing by default
call s:SetDefault('g:vim_json_syntax_conceal', 0)

call s:SetDefault('g:filetype_euphoria', 'elixir')

if !exists('g:python_highlight_all')
  call s:SetDefault('g:python_highlight_builtins', 1)
  call s:SetDefault('g:python_highlight_builtin_objs', 1)
  call s:SetDefault('g:python_highlight_builtin_types', 1)
  call s:SetDefault('g:python_highlight_builtin_funcs', 1)
  call s:SetDefault('g:python_highlight_builtin_funcs_kwarg', 1)
  call s:SetDefault('g:python_highlight_exceptions', 1)
  call s:SetDefault('g:python_highlight_string_formatting', 1)
  call s:SetDefault('g:python_highlight_string_format', 1)
  call s:SetDefault('g:python_highlight_string_templates', 1)
  call s:SetDefault('g:python_highlight_indent_errors', 1)
  call s:SetDefault('g:python_highlight_space_errors', 1)
  call s:SetDefault('g:python_highlight_doctests', 1)
  call s:SetDefault('g:python_highlight_func_calls', 1)
  call s:SetDefault('g:python_highlight_class_vars', 1)
  call s:SetDefault('g:python_highlight_operators', 1)
  call s:SetDefault('g:python_highlight_file_headers_as_comments', 1)
  call s:SetDefault('g:python_slow_sync', 1)
endif

" We need it because scripts.vim in vim uses "set ft=" which cannot be
" overridden with setf (and we can't use set ft= so our scripts.vim work)
func! s:Setf(ft)
  if &filetype !~# '\<'.a:ft.'\>'
    let &filetype = a:ft
  endif
endfunc

" Function used for patterns that end in a star: don't set the filetype if the
" file name matches ft_ignore_pat.
" When using this, the entry should probably be further down below with the
" other StarSetf() calls.
func! s:StarSetf(ft)
  if expand("<amatch>") !~ g:ft_ignore_pat && &filetype !~# '\<'.a:ft.'\>'
    let &filetype = a:ft
  endif
endfunc

augroup filetypedetect

" scripts/build inserts here filetype detection autocommands

au! BufNewFile,BufRead,StdinReadPost * if expand("<afile>") !~ g:ft_ignore_pat |
  \ call polyglot#Shebang() | endif

au BufEnter * if &ft == "" && expand("<afile>") !~ g:ft_ignore_pat |
      \ call s:Observe('Shebang') | endif

augroup END

if !has_key(s:disabled_packages, 'autoindent')
  " Code below re-implements sleuth for vim-polyglot
  let g:loaded_sleuth = 1
  let g:loaded_foobar = 1

  " Makes shiftwidth to be synchronized with tabstop by default
  if &shiftwidth == &tabstop
    let &shiftwidth = 0
  endif

  function! s:guess(lines) abort
    let options = {}
    let ccomment = 0
    let podcomment = 0
    let triplequote = 0
    let backtick = 0
    let xmlcomment = 0
    let heredoc = ''
    let minindent = 10
    let spaces_minus_tabs = 0
    let i = 0

    for line in a:lines
      let i += 1

      if !len(line) || line =~# '^\W*$'
        continue
      endif

      if line =~# '^\s*/\*'
        let ccomment = 1
      endif
      if ccomment
        if line =~# '\*/'
          let ccomment = 0
        endif
        continue
      endif

      if line =~# '^=\w'
        let podcomment = 1
      endif
      if podcomment
        if line =~# '^=\%(end\|cut\)\>'
          let podcomment = 0
        endif
        continue
      endif

      if triplequote
        if line =~# '^[^"]*"""[^"]*$'
          let triplequote = 0
        endif
        continue
      elseif line =~# '^[^"]*"""[^"]*$'
        let triplequote = 1
      endif

      if backtick
        if line =~# '^[^`]*`[^`]*$'
          let backtick = 0
        endif
        continue
      elseif &filetype ==# 'go' && line =~# '^[^`]*`[^`]*$'
        let backtick = 1
      endif

      if line =~# '^\s*<\!--'
        let xmlcomment = 1
      endif
      if xmlcomment
        if line =~# '-->'
          let xmlcomment = 0
        endif
        continue
      endif

      " This is correct order because both "<<EOF" and "EOF" matches end
      if heredoc != ''
        if line =~# heredoc
          let heredoc = ''
        endif
        continue
      endif
      let herematch = matchlist(line, '\C<<\W*\([A-Z]\+\)\s*$')
      if len(herematch) > 0
        let heredoc = herematch[1] . '$'
      endif

      let spaces_minus_tabs += line[0] == "\t" ? 1 : -1

      if line[0] == "\t"
        setlocal noexpandtab
        let &l:shiftwidth=&tabstop
        let b:sleuth_culprit .= ':' . i
        return 1
      elseif line[0] == " "
        let indent = len(matchstr(line, '^ *'))
        if (indent % 2 == 0 || indent % 3 == 0) && indent < minindent
          let minindent = indent
        endif
      endif
    endfor

    if minindent < 10
      setlocal expandtab
      let &l:shiftwidth=minindent
      let b:sleuth_culprit .= ':' . i
      return 1
    endif

    return 0
  endfunction

  function! s:detect_indent() abort
    if &buftype ==# 'help'
      return
    endif

    let b:sleuth_culprit = expand("<afile>:p")
    if s:guess(getline(1, 32))
      return
    endif
    let pattern = sleuth#GlobForFiletype(&filetype)
    if len(pattern) == 0
      return
    endif
    let pattern = '{' . pattern . ',.git,.svn,.hg}'
    let dir = expand('%:p:h')
    let level = 3
    while isdirectory(dir) && dir !=# fnamemodify(dir, ':h') && level > 0
      " Ignore files from homedir and root 
      if dir == expand('~') || dir == '/'
        unlet b:sleuth_culprit
        return
      endif
      for neighbor in glob(dir . '/' . pattern, 0, 1)[0:level]
        let b:sleuth_culprit = neighbor
        " Do not consider directories above .git, .svn or .hg
        if fnamemodify(neighbor, ":h:t")[0] == "."
          let level = 0
          continue
        endif
        if neighbor !=# expand('%:p') && filereadable(neighbor)
          if s:guess(readfile(neighbor, '', 32))
            return
          endif
        endif
      endfor

      let dir = fnamemodify(dir, ':h')
      let level -= 1
    endwhile

    unlet b:sleuth_culprit
  endfunction

  setglobal smarttab

  function! SleuthIndicator() abort
    let sw = &shiftwidth ? &shiftwidth : &tabstop
    if &expandtab
      return 'sw='.sw
    elseif &tabstop == sw
      return 'ts='.&tabstop
    else
      return 'sw='.sw.',ts='.&tabstop
    endif
  endfunction

  augroup polyglot-sleuth
    au!
    au FileType * call s:detect_indent()
    au User Flags call Hoist('buffer', 5, 'SleuthIndicator')
  augroup END

  command! -bar -bang Sleuth call s:detect_indent()
endif

func! s:verify()
  if exists("g:polyglot_disabled_not_set")
    if exists("g:polyglot_disabled")
      echohl WarningMsg
      echo "vim-polyglot: g:polyglot_disabled should be defined before loading vim-polyglot"
      echohl None
    endif

    unlet g:polyglot_disabled_not_set
  endif
endfunc

au VimEnter * call s:verify()

" Save polyglot_disabled without postfixes
if exists('g:polyglot_disabled')
  let g:polyglot_disabled = s:new_polyglot_disabled
endif

" restore Vi compatibility settings
let &cpo = s:cpo_save