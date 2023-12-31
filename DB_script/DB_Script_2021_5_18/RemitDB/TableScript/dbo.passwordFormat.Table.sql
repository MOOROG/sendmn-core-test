USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[passwordFormat]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[passwordFormat](
	[rowId] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[loginAttemptCount] [int] NULL,
	[minPwdLength] [int] NULL,
	[pwdHistoryNum] [int] NULL,
	[specialCharNo] [int] NULL,
	[numericNo] [int] NULL,
	[capNo] [int] NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdBy] [varchar](50) NULL,
	[createdDate] [datetime] NULL,
	[modifiedBy] [varchar](50) NULL,
	[modifiedDate] [datetime] NULL,
	[lockUserDays] [float] NULL,
	[invControlNoForDay] [int] NULL,
	[invControlNoContinous] [int] NULL,
	[operationTimeFrom] [time](7) NULL,
	[operationTimeTo] [time](7) NULL,
	[globalOperationTimeEnable] [char](1) NULL,
	[msrepl_tran_version] [uniqueidentifier] NOT NULL,
 CONSTRAINT [pk_idx_passwordFormat_rowId] PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[passwordFormat] ADD  CONSTRAINT [MSrepl_tran_version_default_C3129BE8_0A9C_4A28_A60D_E29DE201DDBD_1377544091]  DEFAULT (newid()) FOR [msrepl_tran_version]
GO
