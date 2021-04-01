libflux_sources = files(
    'Action.vala',
    'Dispatcher.vala',
    'Middleware.vala',
    'Payload.vala',
    'Store.vala',
)

# define all the names and versions
flux_gi_name = 'flux'
flux_gi_version = '1.0'

flux_gi = flux_gi_name + '-' + flux_gi_version
flux_gir = flux_gi + '.gir'
flux_typelib = flux_gi + '.typelib'

include_dir = join_paths(
    get_option('prefix'),
    get_option('includedir'),
    'flux'
)

# compile shared library, generate GIR, header, and vapi file
libflux = library(
    'flux',

    libflux_sources,

    dependencies: [
        libflux_deps,
    ],

    vala_header: 'flux.h',
    vala_vapi: 'flux.vapi',
    vala_gir: flux_gir,

    version: meson.project_version(),
    install: true,
    install_dir: [true, include_dir, true, true],
)

install_data(
    'flux.deps',
    install_dir: join_paths(get_option('datadir'), 'vala', 'vapi')
)

if get_option('introspection')
    # typelib generation isn't automated yet
    g_ir_compiler = find_program('g-ir-compiler')
    custom_target(
        flux_typelib,
        command: [
            g_ir_compiler,
            '--shared-library',
            '@PLAINNAME@',
            '--output',
            '@OUTPUT@',
            join_paths(meson.current_build_dir(), flux_gir),
        ],
        input: libflux,
        output: flux_typelib,
        depends: libflux,
        install: true,
        install_dir: join_paths(get_option('libdir'), 'girepository-1.0'),
    )
endif

libflux_dep = declare_dependency(
    link_with: libflux,
    dependencies: libflux_deps,
    include_directories: [include_directories('.')],
)

# generate pkgconfig file
flux_pc = pkgconfig.generate(
    libflux,
    name: 'flux',
    requires: libflux_deps,
    subdirs: ['flux'],
    description: 'Application architecture for building user interfaces with Vala',
    version: meson.project_version(),
    url: 'https://github.com/manexim/flux',
)
