set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="leet"

hi Normal       term=none cterm=none ctermfg=gray           ctermbg=black
hi NonText      term=none cterm=none ctermfg=darkred        ctermbg=black
hi Function     term=none cterm=none ctermfg=darkcyan       ctermbg=black
hi Statement    term=bold cterm=bold ctermfg=darkblue       ctermbg=black
hi Special      term=none cterm=none ctermfg=red            ctermbg=black
hi SpecialChar  term=none cterm=none ctermfg=cyan           ctermbg=black
hi Constant     term=none cterm=none ctermfg=yellow         ctermbg=black
hi Comment      term=none cterm=none ctermfg=darkgray       ctermbg=black
hi Preproc      term=none cterm=none ctermfg=darkgreen      ctermbg=black
hi Type         term=none cterm=none ctermfg=darkmagenta    ctermbg=black
hi Identifier   term=none cterm=none ctermfg=cyan           ctermbg=black
hi Visual       term=none cterm=none ctermfg=white          ctermbg=blue
hi Search       term=none cterm=none ctermbg=yellow         ctermfg=darkblue
hi Directory    term=none cterm=none ctermfg=green          ctermbg=black
hi WarningMsg   term=none cterm=none ctermfg=blue           ctermbg=yellow
hi Error        term=none cterm=none ctermfg=red            ctermbg=black
hi Cursor       term=none cterm=none ctermfg=cyan           ctermbg=cyan
hi LineNr       term=none cterm=none ctermfg=red            ctermbg=black
hi StatusLine   term=none cterm=none ctermfg=black          ctermbg=8
hi StatusLineNC term=none cterm=none ctermfg=black          ctermbg=8
hi VertSplit    term=none cterm=none ctermfg=black          ctermbg=8
