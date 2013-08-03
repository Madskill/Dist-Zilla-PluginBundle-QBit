package Dist::Zilla::PluginBundle::QBit;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

use namespace::autoclean;

sub configure {
    my ($self) = @_;

    $self->add_plugins(
        ['GatherDir' => {include_dotfiles => 1, exclude_filename => 'debian/changelog'}],
        'PruneCruft',
        'AutoPrereqs',

        'Git::Init',
        ['Git::Check' => {allow_dirty => []}],
        [
            'Git::NextVersion' => {
                first_version     => 0.1,
                version_by_branch => 0,
                version_regexp    => '^(.+)$'
            }
        ],
        ['ChangelogFromGit' => {file_name => 'Changes'}],
        'ChangelogFromGit::Debian::Sequential',

        'License',
        'Readme',
        'MetaYAML',
        'ExecDir',
        'ShareDir',
        'Manifest',
        'MakeMaker',

        'PkgVersion',

        'TestRelease',
        ($self->payload->{'from_test'} ? () : 'ConfirmRelease'),
        [
            'LaunchpadPPA' => {
                ppa => 'qbit-perl/raring',
                $self->payload->{'from_test'}
                ? (debuild_args => '-S -sa -us -uc', dput_args => '--simulate --unchecked')
                : ()
            }
        ],

        ['Git::Commit' => {commit_msg => 'Version %v', add_files_in => ['debian/changelog']}],
        ['Git::Tag'    => {tag_format => '%v'}],

        ($self->payload->{'from_test'} ? () : 'Git::Push')
    );
}

__PACKAGE__->meta->make_immutable;

__END__

=pod

=head1 NAME

Dist::Zilla::PluginBundle::QBit - build and release QBit Framework packages

=head1 DESCRIPTION

It does not generate debian/* files, you must create them by yourself in advance.

=head1 AUTHOR

Sergei Svistunov <svistunov@cpan.org>

=cut