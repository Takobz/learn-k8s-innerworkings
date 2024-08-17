# Build A Pod From Scratch.

In this section we will be building a Pod like component using Linux primitives. This helps show how Unix achieves isolation that allows for containerization. 
This section requires a linux environment to follow (you can use your unix machine or exec into the kind node)

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