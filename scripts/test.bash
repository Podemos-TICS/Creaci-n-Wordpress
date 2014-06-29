string=$1

LEN=$(echo ${#string})

if [ $LEN -lt 5 ]; then
        echo "$string doesn't have at least 5 characters"
else
        echo "$string has 5 or more characters"
fi

string=$2

LEN=$(echo ${#string})

if [ $LEN -lt 1 ]; then
        echo "No third argument"
fi

