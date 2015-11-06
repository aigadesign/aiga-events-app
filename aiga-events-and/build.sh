android update project -p .

# update all library projects
for LIB in `ls ./library-projects`; do
     if [ -d "./library-projects/$LIB" ]; then
           echo Updating $LIB
             android update lib-project -p ./library-projects/$LIB
              fi
          done
