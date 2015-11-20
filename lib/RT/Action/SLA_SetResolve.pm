# BEGIN BPS TAGGED BLOCK {{{
#
# COPYRIGHT:
#
# This software is Copyright (c) 1996-2015 Best Practical Solutions, LLC
#                                          <sales@bestpractical.com>
#
# (Except where explicitly superseded by other copyright notices)
#
#
# LICENSE:
#
# This work is made available to you under the terms of Version 2 of
# the GNU General Public License. A copy of that license should have
# been provided with this software, but in any event can be snarfed
# from www.gnu.org.
#
# This work is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 or visit their web page on the internet at
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.html.
#
#
# CONTRIBUTION SUBMISSION POLICY:
#
# (The following paragraph is not intended to limit the rights granted
# to you to modify and distribute this software under the terms of
# the GNU General Public License and is only of importance to you if
# you choose to contribute your changes and enhancements to the
# community by submitting them to Best Practical Solutions, LLC.)
#
# By intentionally submitting any modifications, corrections or
# derivatives to this work, or any other work intended for use with
# Request Tracker, to Best Practical Solutions, LLC, you confirm that
# you are the copyright holder for those contributions and you grant
# Best Practical Solutions,  LLC a nonexclusive, worldwide, irrevocable,
# royalty-free, perpetual, license to use, copy, create derivative
# works based on those contributions, and sublicense and distribute
# those contributions and any derivatives thereof.
#
# END BPS TAGGED BLOCK }}}

use strict;
use warnings;

package RT::Action::SLA_SetResolve;

use base qw(RT::Action::SLA);

=head2 Prepare

Checks if the ticket has service level defined.

=cut

sub Prepare {
    my $self = shift;

    unless ( $self->TicketObj->SLA ) {
        $RT::Logger->error('SLA::SetResolve scrip has been applied to ticket #'
            . $self->TicketObj->id . ' that has no SLA defined');
        return 0;
    }

    return 1;
}

=head2 Commit

Set the Resolve date accordingly to SLA.

=cut

sub Commit {
    my $self = shift;

    my $ticket = $self->TicketObj;
    my $txn = $self->TransactionObj;
    my $level = $ticket->SLA;
    my $starts = $ticket->StartsObj;
    my $time = $starts->IsSet ? $starts->Unix : $ticket->CreatedObj->Unix;

    my $resolve_due = $self->Due(
        Ticket => $ticket,
        Level => $level,
        Type => 'Resolve',
        Time => $time,
    );
    $RT::Logger->notice(sprintf("SLA::SetResolve(Ticket => %d, Txn => %d, Level => '%s', Time => %d) == %s", $ticket->Id, $txn->Id, $level, $time, $resolve_due || 'undef'));

    return $self->SetDateField( SLAResolve => $resolve_due );
}

1;
