let groups = lib#color#xcterm256_color()

exec 'syn match vimHiTerm contained "\cctermfg="he=e-1 nextgroup=@'.groups[0]
exec 'syn match vimHiTerm contained "\cctermbg="he=e-1 nextgroup=@'.groups[1]
