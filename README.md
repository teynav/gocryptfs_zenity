# gocryptfs_zenity

Is it very very very secure ? Probably no, but it does help you with day to day encryption of your folder that you don't want someone to see when you hand them your laptop.

Why i say not very secure? Because I echo your password to a file and then use that file to feed gocryptfs to open your vault, it deletes the file immedieately afterwards whole existence of file lasts for 1-2 sec depending on system speed.


![image](https://user-images.githubusercontent.com/40721108/114630944-48e90880-9cd9-11eb-904b-3913fb3ee8f0.png)

Either enter your new folder name or select folder you wanna mount in directory 

``` ~/.secret ``` 

all folders are present in here and are mounted in here to random directories.

Done with using your data? You can always unmount all of it anytime
