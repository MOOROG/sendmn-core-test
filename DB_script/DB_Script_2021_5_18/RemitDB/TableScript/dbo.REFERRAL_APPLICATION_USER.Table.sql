USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[REFERRAL_APPLICATION_USER]    Script Date: 5/18/2021 5:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REFERRAL_APPLICATION_USER](
	[rowId] [bigint] IDENTITY(1,1) NOT NULL,
	[referalCode] [varchar](50) NOT NULL,
	[pwd] [varchar](50) NULL,
	[isLocked] [bit] NULL,
	[lockedDate] [datetime] NULL,
	[IsActive] [bit] NULL,
	[IpAddress] [varchar](128) NULL,
	[IsDeleted] [bit] NULL,
	[DeletedDate] [datetime] NULL,
	[DeletedBy] [varchar](100) NULL,
	[LastPwdChangedDate] [datetime] NULL,
	[isforceChangePwd] [bit] NULL,
	[pwdChangeDays] [decimal](18, 0) NULL,
	[pwdChangeWarningDays] [int] NULL,
	[lastLoginDate] [datetime] NULL,
	[wrongPwdCount] [tinyint] NULL,
PRIMARY KEY CLUSTERED 
(
	[rowId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
