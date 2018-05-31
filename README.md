# Gitlab registry cleaner

Out of the box, there is no easy way to delete a special tag of a given image in the Gitlab registry (as of version 10.8).

This image provides a simple script that enables you to delete images easily.
 
## Why?

If you want to do continuous deployment, it is not uncommon to build one image per pipeline in Gitlab. You will typically
tag all your images using the commit SHA or the branch name. You will soon end up having a lot of images in your Gitlab 
registry. Docker images are big, and disk-space is finite so at some point, you will need to have a mechanism to 
automatically delete an image when it is no more needed.

As it turns out, deleting an image is surprisingly difficult, due to a number of outstanding issues:

 - [#20176 - Provide a programmatic method to delete images/tags from the registry](https://gitlab.com/gitlab-org/gitlab-ce/issues/20176)
 - [#21608 - Container Registry API](https://gitlab.com/gitlab-org/gitlab-ce/issues/21608)
 - [#25322 - Create a mechanism to clean up old container image revisions](https://gitlab.com/gitlab-org/gitlab-ce/issues/25322)
 - [#28970 - Delete from registry images for merged branches](https://gitlab.com/gitlab-org/gitlab-ce/issues/28970)
 - [#39490 - Allow to bulk delete docker images](https://gitlab.com/gitlab-org/gitlab-ce/issues/39490)
 - [#40096 - pipeline user $CI_REGISTRY_USER lacks permission to delete its own images](https://gitlab.com/gitlab-org/gitlab-ce/issues/40096)

This image is here to help.

## Usage

You will typically use this image in your `.gitlab-ci.yml` file.

**.gitlab-ci.yml**
```yml
delete_image:
  stage: cleanup
  image: thecodingmachine/gitlab-registry-cleaner:latest
  script:
    - /delete_image.sh registry.gitlab.mycompany.com/path/to/image:$CI_COMMIT_REF_NAME
  when: manual
  environment:
    name: review/$CI_COMMIT_REF_NAME
    action: stop
  only:
  - branches
  except:
  - master
```

The `/delete_image.sh` script takes one single argument: the full path to the image to be deleted (including the tag).

**Important**: for the script to work, you must add a "Secret variable" in Gitlab CI named `CI_ACCOUNT`.
This variable must be in the form `[user]:[password]` where [user] is a Gitlab user that has access to the registry
and [password] is the Gitlab password of the user. This can be regarded obviously as a security issue if you don't trust
all developers who have access to the CI environment (as they will be able to "echo" this secret variable).

This is needed because the default Gitlab registry token available to the CI does not have the rights to delete
an image by default. An issue is opened in Gitlab to fix this issue: [#39490 - Allow to bulk delete docker images](https://gitlab.com/gitlab-org/gitlab-ce/issues/39490)

## Special thanks

All the hard work has been done by [Alessandro Lai](https://engineering.facile.it/blog/eng/continuous-deployment-from-gitlab-ci-to-k8s-using-docker-in-docker/#the-scary-part-deleting-docker-images)
and [Vincent Composieux](https://gitlab.com/gitlab-org/gitlab-ce/issues/21608#note_53674456).

I've only put your ideas in a Docker image.

## Miscellaneous

This image also contains `kubectl` (the command line tool for Kubernetes) that can be useful to perform cleanup actions
in a Kubernetes cluster.
