!***************************************************************************
! init_biomet_out.f90
! -------------------
! Copyright (C) 2011-2015, LI-COR Biosciences
!
! This file is part of EddyPro (TM).
!
! EddyPro (TM) is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! EddyPro (TM) is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with EddyPro (TM).  If not, see <http://www.gnu.org/licenses/>.
!
!***************************************************************************
!
! \brief       Initializes biomet output file
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine InitBiometOut()
    use m_rp_global_var
    use iso_fortran_env
    implicit none

    !> Local variables
    integer :: open_status
    integer :: i
    integer :: dot
    character(PathLen) :: Test_Path
    character(LongOutstringLen) :: header1
    character(LongOutstringLen) :: header2
    character(LongOutstringLen) :: head1_utf8
    character(LongOutstringLen) :: head2_utf8


    !>==========================================================================
    !> EddyPro's biomet output
    if (EddyProProj%out_biomet .and. nbVars > 0) then
        Test_Path = Dir%main_out(1:len_trim(Dir%main_out)) &
                  // EddyProProj%id(1:len_trim(EddyProProj%id)) &
                  // Biomet_FilePadding // Timestamp_FilePadding // CsvExt
        dot = index(Test_Path, CsvExt, .true.) - 1
        Biomet_Path = Test_Path(1:dot) // CsvTmpExt
        open(ubiomet, file = Biomet_Path, iostat = open_status, encoding = 'utf-8')

        !> Initialize string to void
        call Clearstr(header1)
        call Clearstr(header2)
        call Clearstr(head1_utf8)
        call Clearstr(head2_utf8)

        call AddDatum(header1,'date,time,DOY', separator)
        call AddDatum(header2,'[yyyy-mm-dd],[HH:MM],[ddd.ddd]', separator)

        do i = 1, nbVars
            call AddDatum(header1, trim(bVars(i)%label), separator)
            call AddDatum(header2,trim(bVars(i)%pretty_unit_out), separator)
        end do

        call latin1_to_utf8(header1, head1_utf8)
        call latin1_to_utf8(header2, head2_utf8)

        !> Write on output file
        write(ubiomet, '(a)') head1_utf8(1:len_trim(head1_utf8) - 1)
        write(ubiomet, '(a)') head2_utf8(1:len_trim(head2_utf8) - 1)
    end if

    !>==========================================================================
    !> FLUXNET BIOMET output

    !> Even if it was selected for output, FLUXNET biomet is not created if there
    !> are no biomet variables
    if (nbVars <= 0) EddyProProj%out_fluxnet_biomet = .false.

    if (EddyProProj%out_fluxnet_biomet) then
        Test_Path = Dir%main_out(1:len_trim(Dir%main_out)) &
                  // EddyProProj%id(1:len_trim(EddyProProj%id)) &
                  // FLUXNET_BIOMET_FilePadding // Timestamp_FilePadding // CsvExt
        dot = index(Test_Path, CsvExt, .true.) - 1
        FLUXNET_BIOMET_Path = Test_Path(1:dot) // CsvTmpExt
        open(ufnet_b, file = FLUXNET_BIOMET_Path, &
            iostat = open_status, encoding = 'utf-8')

        !> Initialize header strings to void
        call Clearstr(header1)
        call Clearstr(header2)
        call Clearstr(head1_utf8)
        call Clearstr(head2_utf8)

        !> Initial common part
        call AddDatum(header1,'TIMESTAMP', separator)
        call AddDatum(header2,'[yyyymmddHHMMSS]', separator)

        !>======================================================================
        !> Biomet variables
        do i = 1, nbVars
            call AddDatum(header1,trim(bVars(i)%fluxnet_label), separator)
            call AddDatum(header2,trim(bVars(i)%fluxnet_unit_out), separator)
        end do

        call latin1_to_utf8(header1, head1_utf8)
        call latin1_to_utf8(header2, head2_utf8)

        !> Write on output file
        write(ufnet_b, '(a)') head1_utf8(1:len_trim(head1_utf8) - 1)
        write(ufnet_b, '(a)') head2_utf8(1:len_trim(head2_utf8) - 1)
    end if

end subroutine InitBiometOut
