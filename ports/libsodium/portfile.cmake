vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF ${VERSION}
    SHA512 efeb4c0dc352993fc128974abb27e4be60521e85ce191c8c38a84168d4e7d7b1d2c26843250077dd21dadb13678bf56712375e74754eb02100b8cc418ebffb94
    HEAD_REF master
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(lib_linkage "LIB")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(lib_linkage "DLL")
    endif()

    set(LIBSODIUM_PROJECT_SUBPATH "builds/msvc/vs2022/libsodium/libsodium.vcxproj" CACHE STRING "Triplet variable")

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "${LIBSODIUM_PROJECT_SUBPATH}"
        RELEASE_CONFIGURATION "Release${lib_linkage}"
        DEBUG_CONFIGURATION "Debug${lib_linkage}"
    )

    file(INSTALL "${SOURCE_PATH}/src/libsodium/include/sodium.h" "${SOURCE_PATH}/src/libsodium/include/sodium" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/src/libsodium/include/sodium/version.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/sodium")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am" "${CURRENT_PACKAGES_DIR}/include/sodium/version.h.in")

    block(SCOPE_FOR VARIABLES)
        set(PACKAGE_NAME "libsodium")
        set(PACKAGE_VERSION "${VERSION}")
        set(prefix [[unused]])
        set(exec_prefix [[${prefix}]])
        set(includedir [[${prefix}/include]])
        set(libdir [[${prefix}/lib]])
        set(PKGCONFIG_LIBS_PRIVATE "")
        configure_file("${SOURCE_PATH}/libsodium.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsodium.pc" @ONLY)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libsodium.pc" " -lsodium" " -llibsodium")
        if(NOT VCPKG_BUILD_TYPE)
            set(includedir [[${prefix}/../include]])
            configure_file("${SOURCE_PATH}/libsodium.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsodium.pc" @ONLY)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libsodium.pc" " -lsodium" " -llibsodium")
        endif()
    endblock()
else()
    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH "${SOURCE_PATH}"
    )
    vcpkg_install_make()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/include"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )
endif()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/sodium/export.h" "#ifdef SODIUM_STATIC" "#if 1")
endif()

# vcpkg legacy
configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sodiumConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-sodium/unofficial-sodiumConfig.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
