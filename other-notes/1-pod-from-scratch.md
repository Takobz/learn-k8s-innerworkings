# Build A Pod From Scratch.

In this section we will be building a Pod like component using Linux primitives. This helps show how Unix achieves isolation that allows for containerization. 
This section requires a linux environment to follow (you can use your unix machine or exec into the kind node)

<!--List steps we need to get right to have our own Pod within a cluster-->

### Exec Into The Kind Node.
To exec inside the kind cluster's node is like to SSH in the kind cluster's node that in your physical machine.
The kind cluser's node is a Linux container which we can play around in.

To exec in the node run the following commands:  
-  `docker ps` to get the CONTAINER ID of the node created by kind from the output, it should look like this:
```bash
# copy the value of the CONTAINER ID: b8309f9d4479
CONTAINER ID   IMAGE                  COMMAND                  CREATED          STATUS          PORTS                       NAMES
b8309f9d4479   kindest/node:v1.30.0   "/usr/local/bin/entr…"   51 minutes ago   Up 51 minutes   127.0.0.1:41105->6443/tcp   kind-control-plane
```
- run the command: `docker exec -it b8309f9d4479 /bin/bash` to open a bash shell in the container
- this should open the terminal on your physical machine. The terminal will be "SSH'd" into the node's terminal, thus we can see the node's file system.
- The `-it` flags allow us to attach stdin and command styling to our host machine's terminal from the container's terminal.

## Docker is chroot on steriods
Now that we are connected to the node's shell, we can do Linux primitive tasks inside of it without needing a linux machine or VM.  

### What is chroot
chsroot is a means to run a process with it's own dedicated root. That is in linux we can run a process with it's own set of file systems that are not the global ones used by our machine.  

>[!NOTE]
> Think of chroot as means to isolate a sandbox filesystem that our process can use, that is we can run a bash terminal and give it's own set of `/bin` and `/lib` directories that it can fiddle with without breaking our host's filesystem.

### Running Bash with it's own isolated file system (using chroot).
In this section we will explore how to run a bash terminal with it's own filesystem.

This section assumes you have a linux environment or exec'd within the kind node as seen [here](#exec-into-the-kind-node).  

#### A Namespaced Directory.
We will need to create a directory where we can play around in, mine is:
```bash
#box dir will act as our root for the chroot isolated environment
mkdir /home/namespace/box
```
Then we need a set of other directories like so:
```bash
# directories we will be copying our Node's core deps into.
mkdir /home/namespace/box/bin
mkdir /home/namespace/box/lib
mkdir /home/namespace/box/lib64
```

>[!NOTE]
>The directories we created are for purposes so we can copy some essential files that bash will need to run in our small box environment, we are going to copy files from the Node.

Then we need to run some copy commands to copy essesntial files that bash will need.

```bash
cp -v /usr/bin/kill /home/namespace/box/bin
cp -v /usr/bin/ps /home/namespace/box/bin
cp -v /bin/bash /home/namespace/box/bin
cp -v /bin/ls /home/namespace/box/bin

cp -r /lib/* /home/namespace/box/lib/
cp -r /lib64/* /home/namespace/box/lib64
```
As seen in the above script we copied `bash` and some essentail programs like `ls`, `ps` and `kill` into this box environment.  

When this is done we need to mount the `proc` from the Node into our box environment. The proc directory is useful getting process info among other things, so programs like `ps` use it, this is how we mount it:
```bash
#mounting a filesystem of type proc from /proc dir to proc in our box environment
mount -t proc /proc  /home/namespace/box/proc
```

>[!NOTE]
> Because we are mounting proc from our host machine i.e. the node, we will be able to see PIDs the host machine is running within our box environment by running `ps -ax`, which isn't good, we will fix this.

Then now we need to chroot jail our bash program:
```bash
# runs bash with root (/) as /home/namespace/box
chroot /home/namespace/box /bin/bash
```

Now we will have a terminal switch to this environment and we will see something like this:
```bash
bash-5.2# 
```

This will be running bash version 5.2 in our sandbox environment and doing `ls /` which is listing all directories in the root will look like this:
```bash
# showing that bash thinks it's root is box's directory.
bash-5.2# ls /
bin  lib  lib64  proc
```

There we go we were able to isolate the filesystem, but we aren't done here.

#### Isolating the Bash Process
The above notes describe how we can isolate a filesystem for the bash program. If we run:  
```bash
bash-5.2#  ps -ax
```
We will get a result like this:
```bash
# shows all the program in our host machine
```
We can see that doing a `ps -ax` which is to list all running processes our isolated bash can see PIDs of other programs in the host.  
This means our isolated bash can actually `kill <Some-PID>`, this isn't good because now our bash can actually disrupt our host's critical process


##### Linux unshare to the rescue!
To avoid this from happening we will need to use the `unshare` command when running our chroot on the box root.
