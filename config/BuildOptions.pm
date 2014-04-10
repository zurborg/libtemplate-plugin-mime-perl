%BuildOptions = (%BuildOptions,
    NAME                => 'Template::Plugin::MIME',
    AUTHOR              => 'David Zurborg <david@fakenet.eu>',
    VERSION_FROM        => 'lib/Template/Plugin/MIME.pm',
    ABSTRACT_FROM       => 'lib/Template/Plugin/MIME.pm',
    LICENSE             => 'open-source',
    PL_FILES            => {},
    PMLIBDIRS           => [qw[ lib ]],
    PREREQ_PM => {
        'Test::More' => 0,
        'Template' => 2.24,
        'MIME::Entity' => 5.5
    },
    dist => {
        COMPRESS            => 'gzip -9f',
        SUFFIX              => 'gz',
        CI                  => 'git add',
        RCS_LABEL           => 'true',
    },
    clean               => { FILES => 'Template-Plugin-MIME-* *~' },
    depend => {
	'$(FIRST_MAKEFILE)' => 'config/BuildOptions.pm',
    },
);
