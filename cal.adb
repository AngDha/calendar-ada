    --ASSIGNMENT: CIS*3190 A2
    --AUTHOR: Angad Dhaliwal
    --DATE CREATED: Feb 14th 2026
    --DATE UPDATED: Feb 17th 2026
    --DESCRIPTION: makes a calendar in Ada using a text file to generate a header
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Cal is
   --grid to sort weeks in month (max = 6 weeks) and columns (7 days in a week * 3 months so we need 21 columns) helps build the 4x3 grid
   type gridRow is array (1 .. 6, 1 .. 21) of Integer;

   --1-10 numbers by 10 height tall and 7 wide
   fontArr : array(0..9, 1..10, 1..7) of Character;

   --variables
   year : Integer;
   firstDay : Integer;
   lang : Character; 
   curOffset : Integer;  
   File : File_Type;

   -- Checks if year starts at 1582 or greater so its valid in the Gregorian calendar
   function isValid(year : in Integer) return Boolean is
   begin
      return year >= 1582; 
   end isValid;

   --reads the year to start at the first day of the month and the language wanted by user
   procedure readcalinfo(year : out Integer; firstday : out Integer; lang : out Character) is
      yearTemp : Integer;
      y : Integer;
   begin

      loop
         put("Enter the year: ");
         get(yearTemp);

         if isValid(yearTemp) then
            year := yearTemp;
            exit;
         else
            Put_Line("Invalid year. Please try again.");
         end if;
      end loop;
      
      put("Choose language - (E)nglish or (F)rench: ");
      get(lang);

      y := yearTemp - 1;
      firstday := (36 + y + (y / 4) - (y / 100) + (y / 400)) mod 7;

   end readcalinfo;

   --checks if the year is a leep year if divisble by 4 or 400 and if its divisble by 100 not a leep year
   function leapyear(year : in Integer) return Boolean is
   begin

      if (year rem 400 = 0) then
         return True;
      elsif (year rem 100 = 0) then
         return False;
      elsif (year rem 4 = 0) then
         return True;
      else
         return False;

      end if;
   end leapyear;

   --returns the amount of days in the month
   function numdaysinmonth(month : in Integer; year : in Integer) return Integer is
   begin

      --months with 30 days
      case month is 
         when 4 | 6 | 9 | 11 =>
            return 30;

      --febuary special cases leep year or not
         when 2 =>
         if leapyear(year) then
            return 29;
         else
            return 28;
         end if;

         when others =>
            return 31;

      end case;
   end numdaysinmonth;

   --this function builds the calendar layou by filling our grid array with the proper dates by iterating thourgh 3 months at a time
   procedure buildcalendar(year : in Integer; startingMonth : in Integer; dayOffset : in out Integer; grid : out gridRow) is

      daysInMonth : Integer;
      currentDay : Integer; 
      columnStart : Integer;

   begin 
      --intialize our gird by filling in all spots with 0 to then be overwritten
      grid := (others => (others => 0));

      --loop to iterate through the first 3 months and store days in month for the specific month and then finding where the first number lands
      for i in 0 .. 2 loop

         currentDay := 1;
         daysInMonth := numdaysinmonth (startingMonth + i, year);

         --allows each month to be side by side 1-7, 8-14, 15-21
         columnStart := i * 7;
      
         --loops for the weeks 1-6 (6 is max weeks) and the days in a week
         for j in 1 .. 6 loop
            for n in 1 .. 7 loop

               --leave slots empty till we reach the day of the month we are on so it can handle follow calendar rules
               if (j = 1 and n <= dayOffset) then
                  null;
               
               --ensures we print only the amount of days in the specific month dont exceed
               elsif currentDay <= daysInMonth then
                  grid(j, columnStart + n) := currentDay;
                  currentDay := currentDay + 1;
               end if;               
            end loop;
         end loop;

         --update the offset for the next month by adding current month then mod 7 to get next starting day index
         dayOffset := (dayOffset + daysInMonth) mod 7;

      end loop;

   end buildcalendar;

   --function to print month names and the headers for each day
   procedure printrowheading(startingMonth : in Integer; lang : in Character) is
      --array for 12 months with max length of 10 characters
      type monthnameArray is array (1 .. 12) of String(1 .. 10); 
      
      engMonths : constant monthNameArray := (
         "January   ", "February  ", "March     ", "April     ", 
         "May       ", "June      ", "July      ", "August    ", 
         "September ", "October   ", "November  ", "December  ");
         
      frenchMonths : constant monthNameArray := (
         "Janvier   ", "Fevrier   ", "Mars      ", "Avril     ", 
         "Mai       ", "Juin      ", "Juillet   ", "Aout      ", 
         "Septembre ", "Octobre   ", "Novembre  ", "Decembre  ");

      engDays : constant String := "Su Mo Tu We Th Fr Sa";
      frenchDays : constant String := "Di Lu Ma Me Je Ve Sa";

   begin

      --first 3 months ask language then put the name of the month and following spaces for indentetation
      for i in 0 .. 2 loop
         Put("     ");
         if lang = 'E' or lang = 'e' then
            Put(engMonths(startingMonth + i) & "           ");
         else
            Put(frenchMonths(startingMonth + i) & "           ");
         end if;
      end loop;

      New_Line;

      --first 3 months put the headers with following spaces
      for i in 0 .. 2 loop
         put(" ");
         if lang = 'E' or lang = 'e' then
            Put(engDays & "   "); 
         else
            Put(frenchDays & "   ");
         end if;
      end loop;

      New_Line;

   end printrowheading;

   --iterate through the grid and print 3 months side by side
   procedure printrowmonth(grid : in gridRow) is
   begin

      --iterates through the max weeks and the 21 columns in the gird 
      for i in 1 .. 6 loop
         for j in 1 .. 21 loop
            
            --if no number in the grid fill it with a space
            if grid(i, j) = 0 then
               put("   ");

            --print the date with a width of 3 so numbers are nicely aligned
            else
               Put(grid(i, j), Width => 3);
            end if;

            --after every 7 days add a space to seprate months
            if j rem 7 = 0 then
               put("   ");
            end if;

         end loop;

         New_Line;

      end loop;

      New_Line;

   end printrowmonth;

   --prints out the banner at the top of the screen indented properly
   procedure banner(year : in Integer; indent : in Integer) is

      --convert year to a string
      yearStr : constant String := Integer'Image(year);

   begin

      --loop to iterate through the height and the indent
      for i in 1 .. 10 loop 
         --print the leading indent for alignment
         for j in 1 .. indent loop
            put(" ");
         end loop;

         --loop iterates through each digit character in the year string
         for position in 2 .. yearStr'Last loop
            declare
               --convert character to its integer value
               Digit : constant Integer := Character'Pos(yearStr(position)) - Character'Pos('0');
            begin 
               --print the 7 wide current digit for row 'i'
               for column in 1 .. 7 loop
                  Put(fontArr(Digit, i, column));
               end loop;
               
               Put("  ");

            end;
         end loop;

         New_Line;
      end loop;
   end banner;

begin

   --open the font file
   Open(File, In_File, "font.txt");
   for i in 0 .. 9 loop
      for j in 1 .. 10 loop
         for n in 1 .. 7 loop
            --read each individual character for each digit into the 3d array
            Get(File, fontArr(i, j, n));
         end loop;

         --skip the the newline at the end of the file
         if not End_Of_File(File) then
            Skip_Line(File);
         end if;
      end loop;
   end loop;
   Close(File);

   readcalinfo (year, firstday, lang);
   banner(year, 20);
   New_Line(2);

   --set intial offset to the first day of the month
   curOffset := firstDay;

   --loop 4 times to print 4 rows that consist of 3 months each
   for i in 0 .. 3 loop
      declare
         --temp grid for each of hte 3 months
         currentGrid : gridRow;
         --every 3 months 1 = jan, 4 = apr, 7 = july, 10 = oct which is our starting month for every new row
         startingMonth : Integer := (i * 3) + 1;
      begin
         buildcalendar(year, startingMonth, curOffset, currentGrid);
         printrowheading(startingMonth, lang);
         printrowmonth(currentGrid);
      end;
   end loop;
end Cal;