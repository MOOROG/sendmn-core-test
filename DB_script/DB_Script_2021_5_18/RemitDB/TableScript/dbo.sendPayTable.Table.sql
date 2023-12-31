USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[sendPayTable]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[sendPayTable](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[country] [varchar](30) NULL,
	[agent] [int] NULL,
	[customerRegistration] [char](1) NULL,
	[newCustomer] [char](1) NULL,
	[collection] [char](1) NULL,
	[id] [char](1) NULL,
	[idIssueDate] [char](1) NULL,
	[iDValidDate] [char](1) NULL,
	[dob] [char](1) NULL,
	[address] [char](1) NULL,
	[city] [char](1) NULL,
	[contact] [char](1) NULL,
	[occupation] [char](1) NULL,
	[company] [char](1) NULL,
	[salaryRange] [char](1) NULL,
	[purposeofRemittance] [char](1) NULL,
	[sourceofFund] [char](1) NULL,
	[rId] [char](1) NULL,
	[rPlaceOfIssue] [char](1) NULL,
	[raddress] [char](1) NULL,
	[rcity] [char](1) NULL,
	[rContact] [char](1) NULL,
	[rRelationShip] [char](1) NULL,
	[nativeCountry] [char](1) NULL,
	[tXNHistory] [char](1) NULL,
	[opeType] [varchar](4) NULL,
	[createdBy] [varchar](30) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[rDOB] [varchar](20) NULL,
	[rIdValidDate] [varchar](20) NULL,
 CONSTRAINT [pk_idx_sendPayTable_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
