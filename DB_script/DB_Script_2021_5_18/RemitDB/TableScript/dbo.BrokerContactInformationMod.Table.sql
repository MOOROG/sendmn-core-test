USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[BrokerContactInformationMod]    Script Date: 5/18/2021 5:16:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BrokerContactInformationMod](
	[Id] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ContactId] [int] NOT NULL,
	[brokerCode] [varchar](20) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Designation] [varchar](80) NULL,
	[Land_Line] [varchar](80) NULL,
	[Ext] [varchar](50) NULL,
	[Mobile] [varchar](20) NULL,
	[Email] [varchar](50) NULL,
	[IsActive] [char](1) NULL,
	[CreatedDate] [datetime] NULL,
	[CreatedBy] [varchar](50) NULL,
	[ModifiedDate] [datetime] NULL,
	[ModifiedBy] [varchar](50) NULL,
	[approvedBy] [varchar](50) NULL,
	[approvedDate] [datetime] NULL,
	[isDeleted] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_BrokerContactInformationMod_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BrokerContactInformationMod] ADD  CONSTRAINT [MSrepl_tran_version_default_0FD1FD00_716F_4D3E_B629_7E6BEC25BD59_1614225101]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
