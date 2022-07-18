###################################### MONGO ###########################################
#connect to MongoDB
library(zoo)

library(mongolite)
m <- mongo(collection = "bikes",  db = "mydb", url = "mongodb://localhost")

#2.1
#read the file with the paths of json files
files_list<- read.delim("C:\\Users\\DELL\\Documents\\Msc R\\lab files\\BIKES_DATASET\\BIKES\\files_list.txt", header = FALSE)
files_list[,1]<- gsub("\\", "\\\\", files_list[,1], fixed=TRUE) 

#cleaning and insert data to MongoDB
library(jsonlite)
library(stringr)
for (i in 1:nrow(files_list)) {
  file <- fromJSON(readLines(files_list[i,],encoding = "UTF-8"))
  if (file$ad_data$Price == 'Askforprice')
  {
    file$ad_data$Price <- "NA"
  }
  else {
    file$ad_data$Price <- gsub("[[:punct:]]", "", file$ad_data$Price) #remove the punctuation
    file$ad_data$Price <- gsub("\200", "", file$ad_data$Price) #remove \200 which represents euro
    file$ad_data$Price <- as.numeric(file$ad_data$Price) 
  }
  file$ad_data$Mileage <- gsub(" km", "", file$ad_data$Mileage)
  file$ad_data$Mileage <- gsub(",", "", file$ad_data$Mileage)
  file$ad_data$Mileage <- as.numeric(file$ad_data$Mileage)
  file$ad_data$`Cubic capacity` <- gsub(" cc", "", file$ad_data$`Cubic capacity`)
  file$ad_data$`Cubic capacity` <- gsub(",", "", file$ad_data$`Cubic capacity`)
  file$ad_data$`Cubic capacity` <- as.numeric(file$ad_data$`Cubic capacity`)
  file$ad_data$Power <- gsub(" bhp", "", file$ad_data$Power)
  file$ad_data$Power <- gsub(",", "", file$ad_data$Power)
  file$ad_data$Power <- as.numeric(file$ad_data$Power)
  file$ad_data$`Times clicked` <- as.numeric(file$ad_data$`Times clicked`)
  file$ad_data$Registration <- str_sub(file$ad_data$Registration,-4,-1)
  file$ad_data$Registration <- as.numeric(file$ad_data$Registration)
  file$ad_data$Age <- 2022 - file$ad_data$Registration
  file <- toJSON(file, auto_unbox = TRUE)
  m$insert(file)
}

str(fromJSON(file)) #check the structure of the last file inserted to make sure the cleaning is correct

#2.2

m$count() #29701 bikes are for sale 

#2.3

#we define price over 100 ??? to exclude any unrealistic prices
m$aggregate(
 '[{
	"$match": {
		"ad_data.Price": {
			"$gt": 100
		}
	}
},
{
	"$group": {
		"_id": null,
		"AvgPrice": {
			"$avg": "$ad_data.Price"
		},
		"count": {
			"$sum": 1
		}
	}
}]')  #the average price of a motorcycle is 3,033.61 ??? and the number of listings that were used is 28,461

#2.4
m$aggregate(
  '[{
	"$match": {
		"ad_data.Price": {
			"$gt": 100
		}
	}
},
{
    "$group" : {
      "_id" : null, 
      "MaxPrice" : {
        "$max" : "$ad_data.Price"
      },
		"count": {
			"$max": 1 
		  }
    }
  }]')  #the maximum price of a motorcycle is 89,000 ???

m$aggregate(
  '[{
	"$match": {
		"ad_data.Price": {
			"$gt": 100
		}
	}
},
{
	"$group": {
		"_id": null,
		"MinPrice": {
			"$min": "$ad_data.Price"
		},
		"count": {
			"$sum": 1
		}
	}
}]')  #the minimum price of a motorcycle is 101 ???, given that we only used prices above 100 ???

#2.5

m$aggregate(
  '[{
	"$match": {
		"metadata.model": {
			"$regex": "Negotiable",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": null,
		"count": {
			"$sum": 1
		}
	}
}]')  #the total number of bikes with a price characterized as negotiable are 1,348

#2.8 (Optional)
Top10ByAge<- m$aggregate(
  '[{
  "$group": {
    "_id": {
      "brand": "$metadata.brand"
    },
		"AvgAgePerBrand": {
			"$avg": "$ad_data.Age"
		}
  }
},
{"$sort": {
		"AvgAgePerBrand": -1
	}
},
{
	"$limit": 10
},
{
	"$project": {
		"AvgAgePerBrand": {
			"$round": ["$AvgAgePerBrand",1]
		}
	}
}]') # top ten models with the highest average age 

#2.9 (Optional)
m$aggregate(
  '[{
	"$match": {
		"extras": {
			"$regex": "ABS",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": null,
		"count": {
			"$sum": 1
		}
	}
}]')  # 4,025 motorcycles have ABS as an extra

#2.10
m$aggregate(
  '[{
	"$match": {
		"extras": {
		  "$all" : ["ABS", "Led lights"]
		}
	}
},
{
	"$group": {
		"_id": null,
		"AvgMileage": {
			"$avg": "$ad_data.Mileage"
		}
	}
}]')  #the average Mileage of bikes that have ABS and Led lights as an extra is 30,125.7 km

################################### optional tasks tried but not fully executed ########################################
#2.6
brands_neg <- m$aggregate(
  '[{
	"$match": {
		"metadata.model": {
			"$regex": "Negotiable",
			"$options": "i"
		}
	}
},
{
	"$group": {
		"_id": {
		"brand": "$metadata.brand"
		  },
		"count": {
			"$sum": 1
		}
	}
}]')


#2.7

PricePerBrand <- m$aggregate(
  '[{
	"$match": {
		"ad_data.Price": {
			"$gt": 100
		}
	}
},
{
	"$group": {
		"_id": {
		"brand": "$metadata.brand"
		  },
		"AvgPricePerBrand": {
			"$avg": "$ad_data.Price"
		}
	}
},
{
  "$group" : {
    "_id" : {
		"brand": "$metadata.brand"
		  }, 
	  "MaxPricePerBrand" : {
    "$max": "$AvgPricePerBrand"
	  }
  }
},
{
  "$project": {
    "names": "$_id",
    "MaxAvgPrice": "$MaxPricePerBrand"
    }
}]')


#2.11
Top3ByCategory<- m$aggregate(
  '[{
  "$group": {
    "_id": {
      "category": "$ad_data.Category",
      "color": "$ad_data.Color"
    },
    "color_freq": {
      "$sum": 1
    }
  }
},
{"$sort": {
    "_id.category": -1,
		"color_freq": -1
	}
}]')