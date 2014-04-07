Zip+4s for Congress
======================

For the [congress-forms](https://github.com/EFForg/congress-forms/)/[contact-congress](https://github.com/unitedstates/contact-congress/) project we needed a valid Zip+4 address for each congressional district to use for testing.

### Data generation process:

#### 1. Find district-office data

Find a list of congressional district ofices. The one I used is saved for posterity in the **1- congressional-offices.csv** file, which I found by doing a google search combining a couple of district office addresses (e.g. "3532 Bee Cave Road" + "300 East Eighth Street").

#### 2. Extract data

Since we don't particularly trust any list we find to be up to date, and since we need Bio IDs for each rep, extract the key data (first line of address and zip+4) to the **2- address+zip4.csv** file.

#### 3. Run lookup.rb

Then simply run the lookup.rb script (make sure all dependencies are installed, and add your own Sunlight API key to the code).

The script looks up each address with Google's geocoder to get a lat/lng, then runs each lat/lng through Sunlight's Congress API to get the Bio-ID and congressional district.

The output is just to console, so copy and paste to spreadsheet software (see **3- output.csv**).

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
The output from this stage is in the file **4- output-deduped.csv**.

#### 5. Compare to full list & manually fill in any missing

Remove Senators and out-of-office Reps from Sunlight's [basic legislator information CSV](http://unitedstates.sunlightfoundation.com/legislators/legislators.csv) and then merge Bioguide ID, Rep. Name, State and District columns into **5- output-merged.csv**. 

You might find this USPS Zip+4 Lookup equation useful when filling in missing data:

```
=HYPERLINK("https://tools.usps.com/go/ZipLookupResultsAction!input.action?resultMode=0&companyName=&address1="&SUBSTITUTE(A75," ","+")&"&address2=&city="&SUBSTITUTE(B75," ","+")&"&state="&F75&"&urbanCode=&postalCode=&zip="&D75,"USPS Lookup")
```
You can see this at work in **6- output-cleanup.xlsx**

#### 6. Profit!
Final, cleaned data is in  **7- output-final.csv**.
