USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[NcellFreeSimCampaign]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NcellFreeSimCampaign](
	[id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[controlNo] [varchar](50) NOT NULL,
	[tranType] [varchar](10) NULL,
	[agentId] [int] NULL,
	[firstName] [varchar](200) NULL,
	[lastName] [varchar](200) NULL,
	[mobileNo] [varchar](50) NULL,
	[country] [varchar](100) NULL,
	[zone] [varchar](50) NULL,
	[district] [varchar](50) NULL,
	[idType] [varchar](200) NULL,
	[idNumber] [varchar](100) NULL,
	[idIssueDate] [datetime] NULL,
	[vdcMunicipality] [varchar](max) NULL,
	[contactNo] [varchar](200) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[isDeleted] [varchar](1) NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[extractBy] [varchar](50) NULL,
	[extractDate] [datetime] NULL,
	[activatedBy] [varchar](50) NULL,
	[activatedDate] [datetime] NULL,
	[docReceivedBy] [varchar](50) NULL,
	[docReceivedDate] [datetime] NULL,
	[docSendBy] [varchar](50) NULL,
	[docSendDate] [datetime] NULL,
	[rejectedBy] [varchar](50) NULL,
	[rejectedDate] [datetime] NULL,
 CONSTRAINT [pk_idx_NcellFreeSimCampaign_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
