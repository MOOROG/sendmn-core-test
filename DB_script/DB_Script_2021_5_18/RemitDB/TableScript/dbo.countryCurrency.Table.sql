USE [SendMnPro_Remit]
GO
/****** Object:  Table [dbo].[countryCurrency]    Script Date: 5/18/2021 5:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[countryCurrency](
	[countryCurrencyId] [int] IDENTITY(1,1) NOT NULL,
	[countryId] [int] NULL,
	[currencyId] [int] NULL,
	[applyToAgent] [char](1) NULL,
	[spFlag] [char](1) NULL,
	[isActive] [char](1) NULL,
	[isDeleted] [char](1) NULL,
	[createdDate] [datetime] NULL,
	[createdBy] [varchar](30) NULL,
	[modifiedDate] [datetime] NULL,
	[modifiedBy] [varchar](30) NULL,
	[approvedDate] [datetime] NULL,
	[approvedBy] [varchar](30) NULL,
	[isDefault] [char](1) NULL,
 CONSTRAINT [pk_idx_countryCurrency] PRIMARY KEY CLUSTERED 
(
	[countryCurrencyId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
