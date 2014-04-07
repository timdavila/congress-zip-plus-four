Zip+4s for Congress
======================

For the [https://github.com/EFForg/congress-forms/](congress-forms)/[https://github.com/unitedstates/contact-congress/](contact-congress) project we needed a valid Zip+4 address for each congressional district to use for testing.

### Data generation process:

#### 1. Find district-office data

I found a list of congressional offices, saved for posterity in the [congressional-offices.csv](https://github.com/sinak/congress-zip-plus-four/blob/master/congressional-offices.csv) file, by doing a google search combining a couple of district office addresses (e.g. "3532 Bee Cave Road" + "300 East Eighth Street").

#### 2. Extract data

Since I didn't particularly trust that list to be up to date, and since we need Bio IDs for each rep, extract the key data (first line of address and zip+4) to the **address+zip4.csv** file.

#### 3. Run lookup.rb

Then simply run the lookup.rb script (make sure all dependencies are installed). 
The script looks up each address with Google's geocoder to get a lat/lng, then runs each lat/lng through Sunlight's Congress API to get the Bio-ID and congressional district.
The output is just to console, so copy and paste to spreadsheet software (see **output.csv**).

#### 4. Clean up data

I cleaned up the data little by hand, then used this Excel Macro to remove duplicate entries for congressional districts.
```
Sub DelRowsColASame()
    Dim Lastcell As Range
    Dim I As Long
     
    Set Lastcell = Cells.Find("*", Searchdirection:=xlPrevious)
     
    If Not Lastcell Is Nothing Then
         'delete out a previous row if 1st column matches
        For I = Lastcell.Row To 2 Step -1
            If Cells(I, 9).Value = Cells(I - 1, 9).Value Then
                Cells(I - 1, 9).EntireRow.Delete
            End If
        Next I
    End If
End Sub
```
The output from this stage is in the file output-deduped.csv

#### 5. 
