#!/bin/bash

# List of team members
person_list=("Person 1" "Person 2" "Person 3" "Person 4" "Person 5")

# Working days
working_days=(1 2 3 4 5) # Represents Monday to Friday (1-5)

# Monthly roster file
output_file="monthly_roster.txt"

# Function: Generate a fair roster
generate_roster() {
  month=$1
  year=$2

  total_days=$(cal $month $year | awk 'NF {DAYS = $NF}; END {print DAYS}') # Total days in the month
  current_day=1

  echo "Monthly Roster ($month/$year)" > $output_file
  echo "-----------------------------" >> $output_file

  while [ $current_day -le $total_days ]; do
    day_of_week=$(date -d "$year-$month-$current_day" +%u)

    if [[ " ${working_days[@]} " =~ " $day_of_week " ]]; then
      person1=${person_list[$((($current_day-1) % ${#person_list[@]}))]}
      person2=${person_list[$((($current_day-1 + ${#person_list[@]}/2) % ${#person_list[@]}))]}

      echo "[$current_day/$month/$year] - $person1, $person2" >> $output_file
    fi

    current_day=$((current_day + 1))
  done

  echo "Roster created: $output_file"
}

# Generate the monthly roster
generate_roster "$(date +%m)" "$(date +%Y)"
