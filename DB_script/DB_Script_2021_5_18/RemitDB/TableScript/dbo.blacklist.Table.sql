USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[blacklist]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blacklist](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ofacKey] [varchar](30) NULL,
	[entNum] [varchar](50) NULL,
	[name] [nvarchar](500) NULL,
	[vesselType] [varchar](100) NULL,
	[address] [nvarchar](max) NULL,
	[city] [varchar](200) NULL,
	[state] [varchar](200) NULL,
	[zip] [varchar](100) NULL,
	[country] [varchar](100) NULL,
	[remarks] [nvarchar](max) NULL,
	[sortOrder] [int] NULL,
	[fromFile] [varchar](max) NULL,
	[dataSource] [varchar](100) NULL,
	[indEnt] [char](1) NULL,
	[sourceEntNum] [varchar](30) NULL,
	[MP1] [varchar](200) NULL,
	[MP2] [varchar](200) NULL,
	[MP3] [varchar](30) NULL,
	[MP4] [varchar](30) NULL,
	[MP5] [varchar](30) NULL,
	[MP6] [varchar](30) NULL,
	[MP7] [varchar](30) NULL,
	[MP8] [varchar](30) NULL,
	[MP9] [varchar](30) NULL,
	[MP10] [varchar](30) NULL,
	[MP] [varchar](300) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[isManual] [char](1) NULL,
	[isdeleted] [char](1) NULL,
	[membershipId] [varchar](16) NULL,
	[district] [varchar](100) NULL,
	[idType] [varchar](100) NULL,
	[idNumber] [varchar](50) NULL,
	[dob] [varchar](30) NULL,
	[FatherName] [varchar](200) NULL,
	[isActive] [char](1) NULL,
	[idPlaceIssue] [varchar](50) NULL,
	[contact] [varchar](50) NULL,
 CONSTRAINT [pk_idx_blacklist_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
