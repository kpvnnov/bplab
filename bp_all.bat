@echo off
rem $Id: bp_all.bat,v 1.3 2001-02-26 11:47:00 peter Exp $
echo �������஢���� ��� ������� ��室�����
del *.out
call bp_ekg.bat
call bp_ekg_d.bat
call bp_ekg_s.bat
call bp_ekg_s_d.bat
call bp_noekg.bat
call bp_noekg_d.bat
call bp_noekg_s.bat
call bp_noekg_s_d.bat
