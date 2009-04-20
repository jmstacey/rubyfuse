/* rubyfuse_fuse.h */

/* This is rewriting most of the things that occur
 * in fuse_main up through fuse_loop */

#ifndef __RUBYFUSE_FUSE_H_
#define __RUBYFUSE_FUSE_H_

int rubyfuse_fd();
int rubyfuse_unmount();
int rubyfuse_ehandler();
int rubyfuse_setup(char *mountpoint, const struct fuse_operations *op, char *opts);
int rubyfuse_process();
int rubyfuse_uid();
int rubyfuse_gid();

#endif
