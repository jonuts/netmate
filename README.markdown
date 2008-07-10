NetMate
=======
Netmate is my answer to being forced to use linux.

Usage
-----
To get to the NetMate shell, run:
>$ netmate user:pass@myserver.org:/path/to/file/dir

If you leave off the user/pass (for example if you use an rsa key for authentication), netmate will use your local username.

From the shell you can then run
>> mate file.rb

When you are done editing, you then need to upload the file back up to your server:
>> save file.rb

To see a list of open files to be saved or forgotten:
>> show