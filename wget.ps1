
$sites =@(
    "https://cppreference.com"
)

$sites | ForEach-Object { 
    # use posix wget
    wget --mirror --convert-links --adjust-extension --page-requisites --no-parent $_

}