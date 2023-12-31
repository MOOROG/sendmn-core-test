USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[blacklistHistory]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blacklistHistory](
	[rowId] [bigint] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[blackListId] [bigint] NULL,
	[ofacKey] [varchar](30) NULL,
	[entNum] [varchar](50) NULL,
	[name] [varchar](500) NULL,
	[vesselType] [varchar](100) NULL,
	[address] [varchar](max) NULL,
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
	[isManual] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[membershipId] [varchar](16) NULL,
	[district] [varchar](100) NULL,
	[idType] [varchar](100) NULL,
	[idNumber] [varchar](50) NULL,
	[dob] [varchar](30) NULL,
	[FatherName] [varchar](200) NULL,
	[isActive] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
